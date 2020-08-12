/+  ucal-components, hora
|%
:: TODO: enumerated list of all possible timezones
+$  timezone  @t
+$  title     @t
+$  event-code  @tas
+$  calendar-code  @tas
::
+$  calendar
  $:  owner=@p
      =calendar-code                                    :: internal name, unique
      =title                                            :: external name
      =timezone
      date-created=@da
      last-modified=@da
  ==
::  $event-data: data that makes up an event.
::
+$  event-data
  $:
    =event-code                                       :: unique id
    =calendar-code
    =about                                            :: metadata
    =detail                                           :: title, desc, location
    when=moment:hora
    =invites
    =rsvp                                             :: organizer rsvp
  ==
::  $event: type for calendar events. the optional era determines recurrence
::
+$  event
  $:
    data=event-data
    era=(unit era:hora)
  ==
::  $projected-event: a projected-event represents an event generated by an era.
::  we have a separate type because these shouldn't be storable anywhere,
::  they can be produced by range queries but they can't be persisted.
::
+$  projected-event
  $:
    data=event-data
    source=era:hora
  ==
:: $about: Information about the event, e.g. metadata.
::
+$  about
  $:  organizer=@p
      date-created=@da
      last-updated=@da
  ==
::  $detail: Details about the event itself.
::
+$  detail
  $:  =title
      desc=(unit @t)
      loc=(unit location)
  ==
::
+$  coordinate  $:(lat=@rd lon=@rd)
::  $location: A location has a written address that may or may not
::  resolve to an actual set of geographic coordinates.
::
+$  location
  $:
    address=@t
    geo=(unit coordinate)
  ==
::
::  Those that are invited to the event.
::
+$  rsvp  $?(%yes %no %maybe)
::
+$  invite
  $:  who=@p
      note=@t
      =event-code
      optional=?
      ::  if ~, then the invited party hasn't responded
      rsvp=(unit rsvp)
      sent-at=@da
  ==
::
+$  invites  (map @p invite)
--
