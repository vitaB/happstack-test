module Page.SimpleCalendarList exposing (main, update, view)

import Bootstrap.Alert as Alert
import Bootstrap.ListGroup as ListGroup
import Browser
import Data.SimpleCalendarList exposing (Model, Msg(..), emptyModel)
import Endpoint.CalendarEntryEndpoint exposing (calendarEntriesResponse, loadCalendarEntries)
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    update PerformGetCalendarEntries emptyModel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PerformGetCalendarEntries ->
            ( model, loadCalendarEntries )

        GetCalendarEntriesResult result ->
            ( calendarEntriesResponse result model, Cmd.none )

        OpenCalendarDetialsView _ ->
            --TODO rais logic error exception
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div [ class "calendar-entries" ]
            [ h1 [] [ text "Kalendar Einträge" ]
            , ListGroup.custom
                (List.map
                    (\entry ->
                        ListGroup.button [ ListGroup.attrs [ onClick (OpenCalendarDetialsView entry) ] ] [ text ("description: " ++ entry.description ++ ", start date:" ++ entry.startDate) ]
                    )
                    model.calendarEntries
                )
            ]
        , div [ class "error-messages" ]
            (List.map viewProblem model.problems)
        ]


viewProblem : String -> Html msg
viewProblem problem =
    Alert.simpleDanger [] [ text problem ]