{-# LANGUAGE FlexibleContexts #-}
module Data.Repository.CalendarRepoHelper ( createEntry, removeCalendar ) where

import Happstack.Foundation     ( HasAcidState, query )
import Data.Domain.User                      as User
import Data.Domain.CalendarEntry             as CalendarEntry
import Control.Monad.IO.Class
import Data.Maybe               ( fromJust )

import qualified Data.Repository.UserRepo             as UserRepo
import qualified Data.Repository.CalendarRepo         as CalendarRepo
import qualified Data.Repository.TaskRepo             as TaskRepo
import qualified Data.Repository.Acid.UserAcid        as UserAcid
import qualified Data.Repository.Acid.CalendarAcid    as CalendarAcid
import qualified Data.Repository.Acid.TaskAcid        as TaskAcid

createEntry :: (HasAcidState m CalendarAcid.EntryList, HasAcidState m UserAcid.UserList,
            MonadIO m) => String -> User -> m CalendarEntry
createEntry description user = do
    calendarEntry <- CalendarRepo.createEntry description user
    UserRepo.addCalendarEntryToUser user $ CalendarEntry.entryId calendarEntry
    return calendarEntry

removeCalendar :: (HasAcidState m CalendarAcid.EntryList, HasAcidState m UserAcid.UserList,
      HasAcidState m TaskAcid.TaskList, MonadIO m) => CalendarEntry -> m ()
removeCalendar calendarEntry = let cEntryId = entryId calendarEntry in
    do
       mUser <- query (UserAcid.UserById (CalendarEntry.userId calendarEntry))
       UserRepo.deleteCalendarEntryFromUser (fromJust mUser) cEntryId
       deleteCalendarsTasks calendarEntry
       CalendarRepo.deleteCalendar [cEntryId]

deleteCalendarsTasks :: (HasAcidState m TaskAcid.TaskList, MonadIO m)
    => CalendarEntry -> m ()
deleteCalendarsTasks calendar =
    foldr (\ x ->
      (>>) (do
        mTask <- query (TaskAcid.TaskById x)
        TaskRepo.deleteTask (fromJust mTask) ))
    (return ()) $ CalendarEntry.calendarTasks calendar