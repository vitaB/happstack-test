{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell    #-}
{-# OPTIONS_GHC -fno-warn-missing-fields #-}

module Data.Domain.User
    ( User(..)
    ) where

import           Data.Data         (Data, Typeable)
import           Data.Default
import           Data.SafeCopy     (base, deriveSafeCopy)
import           Data.Text         (Text)

import           Data.Domain.Types (Entity (..), EntryId, TaskId, UserId)

data User = User
    { loginName              :: Text
    , userId                 :: UserId
    , version                :: Int
    , ownerOfCalendarEntries :: [EntryId]
    , assignedToTasks        :: [TaskId]
    } deriving (Eq, Ord, Read, Show, Data, Typeable)

$(deriveSafeCopy 0 'base ''User)

instance Entity User where
    setId user newId = user {userId = newId}
    getId = userId
    setVersion user newVersion = user {version = newVersion}
    getVersion = version
    getUsersAccessRestriction a = [userId a]

instance Default User where
    def = User {userId = -1, version = 0, ownerOfCalendarEntries = [], assignedToTasks = []}
