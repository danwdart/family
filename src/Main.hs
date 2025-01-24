{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-unused-matches -Wno-x-partial #-}

module Main (main) where

import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Except
import Data.Gedcom
import Data.Gedcom.Structure
import Data.Maybe
import Data.Text                  qualified as T
import Data.Text.IO               qualified as TIO

main ∷ IO ()
main = do
    result <- parseGedcomFile "familytree.ged"
    case result of
        Right (gedcom, xref) -> void . runExceptT $ do
            firstPerson <- liftEither . flip gdLookup xref . head $ gedcomIndividual gedcom
            -- let family = rights $ flip gdLookup xref <$> gedcomFamily gedcom
            let personsName = (\(Name a b) -> a) . personalNameName . fromJust . individualName
            let firstPersonName = personsName firstPerson
            let number = length $ gedcomIndividual gedcom
            liftIO . TIO.putStrLn $ "First person named: " <> firstPersonName
            liftIO . TIO.putStrLn $ "Number of individuals: " <> T.show number
            pure ()
        _ -> error "Failure"
