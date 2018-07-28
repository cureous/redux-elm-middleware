port module Redux exposing (program, programWithFlags)

{-| Redux elm middleware
@docs program
-}

import Json.Encode as Json
import Platform


port elmToRedux : ( String, Json.Value ) -> Cmd msg


initActionType =
    "init"


{-| Creates a [Program](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Platform#Program) that defines how your reducer works. This is a convinient wrapper arround [Html.App.programm](http://package.elm-lang.org/packages/elm-lang/html/1.0.0/Html-App#program).
main = Redux.program(
{ init = init
, update = update
, subscriptions
})
-}
program :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , encode : model -> Json.Value
    , subscriptions : model -> Sub msg
    }
    -> Program Never model msg
program app =
    let
        reducer action ( message, cmd ) =
            ( message
            , Cmd.batch
                [ cmd
                , ( toString action
                  , app.encode message
                  )
                    |> elmToRedux
                ]
            )

        wrap update msg model =
            reducer msg <| update msg model

        ( initModel, initCmd ) =
            app.init

        initReduxCmd =
            elmToRedux ( initActionType, app.encode initModel )

        init =
            ( initModel
            , Cmd.batch
                [ initCmd
                , initReduxCmd
                ]
            )
    in
    Platform.program
        { init = init
        , update = wrap app.update
        , subscriptions = app.subscriptions
        }


programWithFlags :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , encode : model -> Json.Value
    , subscriptions : model -> Sub msg
    }
    -> Program flags model msg
programWithFlags app =
    let
        reducer action ( message, cmd ) =
            ( message
            , Cmd.batch
                [ cmd
                , ( toString action
                  , app.encode message
                  )
                    |> elmToRedux
                ]
            )

        wrap update msg model =
            reducer msg <| update msg model

        init flags =
            let
                ( initModel, initCmd ) =
                    app.init flags

                initReduxCmd =
                    elmToRedux ( initActionType, app.encode initModel )
            in
            ( initModel
            , Cmd.batch
                [ initCmd
                , initReduxCmd
                ]
            )
    in
    Platform.programWithFlags
        { init = init
        , update = wrap app.update
        , subscriptions = app.subscriptions
        }
