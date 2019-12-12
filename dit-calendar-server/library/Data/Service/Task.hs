{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE MonoLocalBinds       #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-}

module Data.Service.Task
    ( deleteTaskAndCascadeImpl, createTaskInCalendarImpl, updateTaskInCalendarImpl, TaskService(..) ) where

import           Control.Monad.IO.Class

import           AppContext                   (App)
import           Data.Domain.CalendarEntry    as CalendarEntry
import           Data.Domain.Task             as Task
import           Data.Domain.Types            (EitherResult)

import           Data.Repository.CalendarRepo (MonadDBCalendarRepo)
import qualified Data.Repository.CalendarRepo as MonadDBCalendarRepo
import           Data.Repository.TaskRepo     (MonadDBTaskRepo)
import qualified Data.Repository.TaskRepo     as TaskRepo
import           Data.Service.UserTasks       (UserTasksService)
import qualified Data.Service.UserTasks       as UserTasksService


deleteTaskAndCascadeImpl :: (MonadDBTaskRepo m, UserTasksService m, MonadIO m, MonadDBCalendarRepo m) => CalendarEntry -> Task -> m ()
deleteTaskAndCascadeImpl calendar task = do
    MonadDBCalendarRepo.deleteTaskFromCalendarEntry calendar (taskId task)
    UserTasksService.deleteTaskFromAllUsers task
    TaskRepo.deleteTask task

createTaskInCalendarImpl :: (MonadDBTaskRepo m, MonadDBCalendarRepo m) =>
            CalendarEntry -> Task -> m Task
createTaskInCalendarImpl calendarEntry task = do
    mTask <- TaskRepo.createTask task
    MonadDBCalendarRepo.addTaskToCalendarEntry calendarEntry (Task.taskId mTask)
    return mTask

updateTaskInCalendarImpl :: MonadDBTaskRepo m => Task -> m (EitherResult Task)
updateTaskInCalendarImpl = TaskRepo.updateTask

class Monad m => TaskService m where
    deleteTaskAndCascade :: CalendarEntry -> Task -> m ()
    createTaskInCalendar :: CalendarEntry -> Task -> m Task
    updateTaskInCalendar :: Task -> m (EitherResult Task)

instance (MonadDBTaskRepo App, MonadDBCalendarRepo App) => TaskService App where
    deleteTaskAndCascade = deleteTaskAndCascadeImpl
    createTaskInCalendar = createTaskInCalendarImpl
    updateTaskInCalendar = updateTaskInCalendarImpl
