module Controller.UserController where

import Happstack.Server         ( ok, toResponse, lookRead 
                                , Method(GET), method)
import Happstack.Foundation     ( query, update )

import Domain.User              as User      ( User(..))
import Domain.Types             ( UserId, EntryId )
import Repository.Acid.UserAcid as UserAcid
import Repository.UserRepo      as UserRepo
import Controller.AcidHelper    ( CtrlV )

--handler for userPage
userPage :: UserId -> CtrlV
userPage i =
    do
       mUser <- query (UserAcid.UserById i)
       case mUser of
            Nothing ->
                ok $ toResponse $ "Could not find a user with id " ++ show i
            (Just u) ->
                ok $ toResponse $ "peeked at the name and saw: " ++ show u

--handler for userPage
usersPage :: CtrlV
usersPage =
    let temp = "Anzeige aller User \n" in
    do method GET
       userList <- query UserAcid.AllUsers
       case userList of
            [] ->
                ok $ toResponse (temp ++ "Liste ist leer")
            (x:xs) ->
                ok $ toResponse $ temp ++ printUsersList (x:xs)

createUser :: String -> CtrlV
createUser name =
    do
        mUser <- update (UserAcid.NewUser name)
        ok $ toResponse $ "User created: " ++ show mUser
        
deleteUser :: UserId -> CtrlV
deleteUser i = 
    do
        mUser <- update (UserAcid.DeleteUser i)
        ok $ toResponse $ "User with id:" ++ show i ++ "deleted"

printUsersList :: [User] -> String
printUsersList l = case l of
    --schlechte implementierung. es gibt dafür schon fertige funktionen (annonyme funktion uebergeben)
    []     -> ""
    (x:xs) -> ("User: " ++ User.name x ++ "mit Id: "++ show (User.userId x))
        ++ "\n" ++ printUsersList xs

addCalendarEntryToUser :: User -> EntryId -> CtrlV
addCalendarEntryToUser user entryId = do 
    mUser <- UserRepo.addCalendarEntryToUser user entryId
    ok $ toResponse $ "Add Entry: " ++ show entryId ++ "to User: " ++ show (User.userId user)

