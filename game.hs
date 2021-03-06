{-# LANGUAGE OverloadedStrings #-}
module Main where


import Control.Monad (msum)
import Data.List (delete)
import qualified Data.Array as AR
import Happstack.Server
import Happstack.Server.Types (Response, addHeader)
import qualified Data.Text.Lazy as L
import Text.Blaze ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import Text.Blaze.Svg11 ((!))
import qualified Text.Blaze.Svg11 as S
import qualified Text.Blaze.Svg11.Attributes as SA

keys :: Int -> Int -> [Int]
keys l x = delete x $ row l (x+l) ++ row l x ++ row l (x-l) 
  where row l x
          | 0<=x && x<l*l = map preserveRow thisRow
          | x>=l*l = row l (x `mod` l)
          | x<0 = row l (l*l + x) 
          where thisRow = [x`mod`l-1, x`mod`l, x`mod`l+1]
                preserveRow = (\y->y`mod`l+l*(x `div` l))

action :: Int -> Int -> AR.Array Int Int -> Int
action l x xs = if (s==3)||(s==2&& xs AR.! x==1) then 1 else 0   
  where s=sum $ map (xs AR.!) $ keys l x

step :: Int -> AR.Array Int Int -> [Int]
step l xs = [l]++map (\x->action l x xs) [0..l*l-1]

main :: IO ()
main = do
    putStrLn "Now running on http://127.0.0.1:8000/"
    simpleHTTP nullConf $ handlers

myPolicy :: BodyPolicy
myPolicy = (defaultBodyPolicy "/tmp/" 0 10000 10000)

handlers :: ServerPart Response
handlers =
    do decodeBody myPolicy
       msum [ dir "game" $ processRequest 
            , dir "js" $ serveDirectory DisableBrowsing [] "./js/"
            , nullDir >> page
            ]

processRequest :: ServerPart Response
processRequest =
    do methodM POST
       stateStr <- look "state"
       let state = read stateStr :: [Int]
       let l = head state
       let maxI = l*l-1
       let stateArr = AR.array (0, maxI) $ zip [0..] $ tail state
       let newState = step l stateArr
       let r = toResponse (show newState)
       ok $ addHeader "Access-Control-Allow-Origin" "*" r

page :: ServerPart Response
page = ok $ toResponse $
            H.html $ do
                H.script ! A.type_ "text/javascript" ! A.src "js/jquery-3.1.1.min.js" $ ""
                H.script ! A.type_ "text/javascript" ! A.src "js/d3.min.js" $ ""
                H.script ! A.type_ "text/javascript" ! A.src "js/buttons.js" $ ""
                H.script ! A.type_ "text/javascript" ! A.src "js/script.js" $ ""
                H.head $ do
                    H.title $ "Game of Life"
                H.body $ do
                    svgDoc
                    H.p ! A.id "state" ! A.hidden "true" $ "[5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]"
                    H.br
                    H.button ! A.onclick "fetch()" $ "Step Forward"
                    H.button ! A.onclick "changeSpeed(50)" $ "Speed-"
                    H.button ! A.onclick "changeSpeed(-50)" $ "Speed+"
                    H.button ! A.id "pausebtn" ! A.onclick "togglePause()" $ "Pause"
                    H.br
                    H.button ! A.onclick "changeGrid(-1)" $ "grid-"
                    H.button ! A.onclick "changeGrid(1)" $ "grid+"

svgDoc = S.svg ! SA.version "1.1" ! SA.width "150" ! SA.height "100" $ ""
                   