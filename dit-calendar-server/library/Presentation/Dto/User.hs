{-# LANGUAGE DeriveGeneric #-}
{-# OPTIONS_GHC -fno-warn-missing-fields #-}

module Presentation.Dto.User
    ( User(..)
    , validate
    ) where

import           Data.Aeson
import           Data.Default
import           Data.Maybe   (isJust)
import           Data.Text
import           GHC.Generics

data User = User
    { loginName :: Text
    , userId    :: Maybe Int
    , version   :: Maybe Int
    } deriving (Show, Generic)

validate :: Either String User -> Either String User
validate (Left e) = Left e
validate (Right user) =
    if isJust $ userId user
    then if isJust $ version user
        then Right user
        else Left "version is missing"
    else Right user

instance ToJSON User where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON User where
    parseJSON = genericParseJSON defaultOptions {omitNothingFields = True}

instance Default User where
    def = User {userId = Nothing, version = Nothing}
