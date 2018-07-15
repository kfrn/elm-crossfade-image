module Main exposing (..)

import Animation
import Animation.Messenger
import Html exposing (Html, button, div, h1, img, text)
import Html.Attributes exposing (class, id, src)
import Html.Events exposing (onClick)


---- MODEL ----


type alias Model =
    { img1 : Animation.Messenger.State Msg
    , img2 : Animation.Messenger.State Msg
    }


init : ( Model, Cmd Msg )
init =
    ( { img1 = Animation.style [ Animation.opacity 1.0 ]
      , img2 = Animation.style [ Animation.opacity 0.0 ]
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = Animate Animation.Msg
    | Crossfade
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate animMsg ->
            ( { model
                | img1 = Animation.update animMsg model.img1
                , img2 = Animation.update animMsg model.img2
              }
            , Cmd.none
            )

        Crossfade ->
            let
                newOpacity1 : Float
                newOpacity1 =
                    if isOpaque model.img1 then
                        0.0
                    else
                        1.0

                isOpaque : Animation.Messenger.State Msg -> Bool
                isOpaque style =
                    Debug.log "isOpaque" <| style == Animation.style [ Animation.opacity 1.0 ]

                newOpacity2 : Float
                newOpacity2 =
                    if newOpacity1 == 1.0 then
                        0.0
                    else
                        1.0

                _ =
                    Debug.log "img1" model.img1

                --
                -- _ =
                --     Debug.log "newOpacity1" newOpacity1
                --
                -- _ =
                --     Debug.log "img2" model.img2
                --
                -- _ =
                --     Debug.log "newOpacity2" newOpacity2
            in
            ( { model
                | img1 =
                    Animation.interrupt
                        [ Animation.to
                            [ Animation.opacity newOpacity1 ]
                        ]
                        model.img1
                , img2 =
                    Animation.interrupt
                        [ Animation.to
                            [ Animation.opacity newOpacity2 ]
                        ]
                        model.img2
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Crossfade between images demo" ]
        , div
            [ id "kate-image" ]
            [ img (Animation.render model.img1 ++ [ src "./babooshka_double-bass.jpg" ]) []
            , img (Animation.render model.img2 ++ [ src "./babooshka_warrior.jpg" ]) []
            ]
        , button [ class "button", onClick Crossfade ] [ text "Crossfade!" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.img1, model.img2 ]
