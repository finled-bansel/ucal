|%
::  $ical-time:  type for ics dates or datetimes
::
::    many fields in the rfc are specified as either
::    a date OR a date-time. this type contains both
::
+$  ical-time
  $%
    [%date d=date]
    [%date-time d=date utc=?]
  ==
::  $ical-date:  type for ics dates
::
+$  ical-date  $>(%date ical-time)
::  $ical-datetime:  type for ics datetimes
::
+$  ical-datetime  $>(%date-time ical-time)
::  $ical-duration:  a signed duration
::
+$  ical-duration  $:(sign=? t=tarp)
::  $event-ending:  we either have end date or positive duration
::
+$  event-ending
  $%
    [%dtend d=ical-time]
    [%duration t=tarp] ::  always a positive duration
  ==
::  $event-class:  the different classes of event per the rfc
::
+$  event-class
  $?
    %public
    %private
    %confidential
  ==
::  $event-status:  event statuses per the rfc
::
+$  event-status  ?(%tentative %confirmed %cancelled)
::  $latlon:  type for a latitude and a longitude, two floating points
::
+$  latlon  $:(lat=dn lon=dn)
::  $period:  ics period per the rfc
::
+$  period
  $%
    [%explicit begin=ical-datetime end=ical-datetime]
    [%start begin=ical-datetime duration=tarp] ::  always a positive duration
  ==
::  $rdate:  definition for an ics rdate
::
::    rdates are used to compute the recurrence set of an event (i.e.
::    the set of dates the event recurs on). rdates are specific
::    additional dates to include in the set.
::
+$  rdate
  $%
    [%time d=ical-time]
    [%period p=period]
  ==
::  $rrule:  a recurrence rule as defined by the rfc. used to compute the
::  recurrence set for an event.
::
+$  rrule
  $:
    ::  freq is the only required part
    ::
    freq=rrule-freq
    ::  ending date for event
    ::
    until=(unit ical-time)
    ::  number of occurrences
    ::
    count=(unit @)
    ::  interval times freq gives the intervals at which
    ::  the recurrence occurs. The default is 1
    ::
    interval=$~(1 @)
    ::  These lists contain intervals that (depending on freq) either
    ::  increase or constrain the size of the recurrence set. See
    ::  rfc 5545 page 44 for more info
    ::
    bysecond=(list @)
    byminute=(list @)
    byhour=(list @)
    byweekday=(list rrule-weekdaynum)
    bymonthday=(list rrule-monthdaynum)
    byyearday=(list rrule-yeardaynum)
    byweek=(list rrule-weeknum)
    bymonth=(list rrule-monthnum)
    bysetpos=(list rrule-setpos)
    ::  start of workweek, default is monday
    ::
    weekstart=$~(%mo rrule-day)
  ==
::  $rrule-freq:  frequency an rrule can repeat at
::
+$  rrule-freq
  $?
    %secondly
    %minutely
    %hourly
    %daily
    %weekly
    %monthly
    %yearly
  ==
::  $rrule-day:  days of the week, sunday to saturday
::
+$  rrule-day
  $?
    %su
    %mo
    %tu
    %we
    %th
    %fr
    %sa
  ==
::  $rrule-weekdaynum: specifies a day of the week and an optional
::  nth occurrence within a monthday or yearday rule
::
+$  rrule-weekdaynum
  $:
    day=rrule-day
    weeknum=(unit rrule-weeknum)
  ==
::  $rrule-monthdaynum:  a signed day of the month
::
::    -10 would represent 10 days from the end of the month,
::    while 20 would be 20 days from the start of the month.
::
+$  rrule-monthdaynum  @s
::  $rrule-yeardaynum:  a signed day of the year
::
::    -10 would represent 10 days from the end of the year,
::    while 20 would be 20 days from the start of the year.
::
+$  rrule-yeardaynum  @s
::  $rrule-weeknum:  a signed week of the year
::
::    -10 would represent 10 weeks from the end of the year,
::    while 20 would be 20 weeks from the start of the year.
::
+$  rrule-weeknum  @s
::  $rrule-monthnum:  a month of the year, 1-12
::
+$  rrule-monthnum  @s
::  $rrule-setpos:  represents a specific instance generated by the rrule.
::
::    -1 would represent the last instance generated in an interval
::    of an rrule. 2 would be the second one generated.
::
+$  rrule-setpos  @s
::  $vevent-transparency:  vevent transparencies, opaque is default
::
+$  vevent-transparency
  $?
    %transparent
    %opaque
  ==
::  $vevent:  definition of a vevent per the rfc
::
+$  vevent
    $:
      ::  Required Fields
      ::  date event was created (always a date-time)
      ::
      dtstamp=ical-datetime
      ::  unique id
      ::
      uid=cord
      ::  start of event
      ::
      dtstart=ical-time
      ::  end of our event
      ::
      end=event-ending
      ::
      ::  Optional Fields, all either unit or lists?
      ::
      ::  event organizer
      ::
      organizer=(unit tape)
      ::  categories the event falls under
      ::
      categories=wall :: (list tape)
      ::  Access classifications for calendar event (basically permissions)
      ::
      classification=(unit event-class)
      ::  comments from event creator on the event
      ::
      comment=wall :: (list tape)
      ::  description of the event
      ::
      description=(unit tape)
      ::  summary of event
      ::
      summary=(unit tape)
      ::  lat/lon where the event is occurring
      ::
      geo=(unit latlon)
      ::  a location of the event
      ::
      location=(unit tape)
      ::  event status
      ::
      status=(unit event-status)
      ::  nested components - for vevents only valarms can be nested
      ::
      alarms=(list valarm)
      ::  recurrence rule
      ::
      rrule=(unit rrule)
      ::  list of dates to include in the recurrence set
      ::
      rdate=(list rdate)
      ::  list of dates to exclude from the recurrence set
      ::
      exdate=(list ical-time)
      ::  creation and update times - these must be UTC date-times
      ::  since they must be UTC, we can just store the date
      ::
      created=(unit date)
      ::  time event was last modified
      ::
      last-modified=(unit date)
      ::  revision sequence number, defaults to 0
      ::
      sequence=@
      ::  event transparency, how it appears to others who
      ::  look at your schedule.
      ::
      transparency=vevent-transparency
      ::  event priority, 0-9. 0 is undefined, 1 is highest prio, 9 lowest
      ::
      priority=@
      ::  url associated w/event
      ::
      url=(unit tape)
    ==
::  $valarm-action:  actions assosiated with valarms. each one has
::  different data associated with it.
::
+$  valarm-action  ?(%audio %display %email)
::  $valarm-related:  a trigger can be related to the
::  start or end of an event.  default is start
::
+$  valarm-related  ?(%end %start)
::  $valarm-trigger:  trigger for a valarm, determines when the alarm fires
::
+$  valarm-trigger
  $%
    [%rel related=valarm-related duration=ical-duration]
    [%abs dt=ical-datetime]
  ==
::  $valarm-duration-repeat:  the positive duration to repeat an alarm on
::  along with the count.
::
+$  valarm-duration-repeat  $:(duration=tarp repeat=@)
::  $valarm-audio:  audio alarm component
::
+$  valarm-audio
  $:
    ::  Required fields
    ::
    trigger=valarm-trigger
    ::  Optional fields
    ::
    duration-repeat=(unit valarm-duration-repeat)
    ::  a url that points to an audio resource to be played
    ::  when the alarm triggers
    ::
    attach=(unit tape)
  ==
::  $valarm-display:  text display alarm component
::
+$  valarm-display
  $:
    ::  Required fields
    ::
    trigger=valarm-trigger
    ::  text to display
    ::
    description=tape
    ::  Optional fields
    ::
    duration-repeat=(unit valarm-duration-repeat)
  ==
::  $valarm-email:  email alarm component
::
+$  valarm-email
  $:
    ::  Required fields
    ::
    trigger=valarm-trigger
    ::  email body
    ::
    description=tape
    ::  email subject
    ::
    summary=tape
    ::  email addresses to send to - must be at least one
    ::
    attendees=(lest tape)
    ::  Optional fields
    ::
    ::  list of urls to attach to the email
    ::
    attach=(list tape)
  ==
::  $valarm:  definition of a valarm per the rfc
::
+$  valarm
  $%
    [%audio audio=valarm-audio]
    [%display display=valarm-display]
    [%email email=valarm-email]
  ==
::  $tzid:  uniquely identifies a VTIMEZONE
::
+$  tzid  tape
::  $utc-offset:  an offset from a local time to utc
::
+$  utc-offset  [sign=? delta=tarp]
::  $tzprop:  represents a specific timezone
::
+$  tzprop
  $:
    ::  Required fields
    ::
    ::  Must be "local time" i.e. NOT utc and no TZID,
    ::  so just an urbit date
    ::
    dtstart=date
    tzoffsetto=utc-offset
    tzoffsetfrom=utc-offset
    ::  Optional fields
    ::
    rrule=(unit rrule)
    rdate=(list rdate)
    comments=(list tape)
    tzname=(list tape)
  ==
::  $tzcomponent:  a tzprop can either refer to standard time or
::  daylight savings time
::
+$  tzcomponent
  $%
    [%standard s=tzprop]
    [%daylight d=tzprop]
  ==
::  $vtimezone:  represents a parsed ics timezone
::
+$  vtimezone
  $:
    ::  Required fields
    ::
    id=tzid
    props=(list tzcomponent)
    ::  Optional fields
    ::
    last-modified=(unit ical-datetime)
    url=(unit tape)
  ==
--
