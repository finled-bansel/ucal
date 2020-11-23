:: TODO:
:: - set up scry paths
:: - poke
:: - ucal.hoon -> ucal-store.hoon/calendar-store.hoon
::
/-  ucal, ucal-almanac, ucal-store, *resource
/+  default-agent, *ucal-util, alma-door=ucal-almanac, ucal-parser
::
::: local type
::
|%
:: aliases
+$  card   card:agent:gall
+$  cal    calendar:ucal
+$  event  event:ucal
+$  event-data  event-data:ucal
+$  projected-event  projected-event:ucal
+$  calendar-code  calendar-code:ucal
+$  event-code  event-code:ucal
+$  almanac  almanac:ucal-almanac
++  al  al:alma-door
::
+$  state-zero
  $:
    alma=almanac ::  maintains calendar and event states
  ==
::
+$  versioned-state
  $%
    [%0 state-zero]
  ==
--
::
::: state
::
=|  state=versioned-state
::
::: gall agent definition
::
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .                                           :: the agent itself
      uc    ~(. +> bowl)                                :: helper core
      def   ~(. (default-agent this %|) bowl)           :: default/"stub" arms
  ++  on-init  on-init:def
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load  ::on-load:def
    |=  =vase
    ^-  (quip card _this)
    :-  ~                                               :: no cards to emit
    =/  prev  !<(versioned-state vase)
    ?-  -.prev
      %0  this(state prev)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+    mark  `this
        %noun
      ?>  (team:title our.bowl src.bowl)
      ::
      :: these are for debugging
      ::
      ?+    q.vase  (on-poke:def mark vase)
          %print-state
        ~&  state
        `this  :: irregular syntax for '[~ this]'
      ::
          %reset-state
        `this(state *versioned-state)  :: irregular syntax for bunt value
      ==
    ::
        %ucal-action
      =^  cards  state  (poke-ucal-action:uc !<(action:ucal-store vase))
      [cards this]
    ::
        %ucal-to-subscriber
      ::  this is where updates from ucal-pull-hook come through.
      ~&  %ucal-to-subscriber-via-poke
      =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
      ~&  [%ts ts]
      `this
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    :_  this
    ~&  [%store-on-watch path]
    ::  NOTE: the store sends subscription updates on /almanac that are proxied
    ::  by ucal-push-hook. However, since these are per-calendar, there's no
    ::  initial state we want to send here.
    ?+  path  (on-watch:def path)
        [%almanac ~]  ~
    ==
  ++  on-agent
    |~  [=wire =sign:agent:gall]
    ~&  [%ucal-store-on-agent wire sign]
    (on-agent:def wire sign)
  ++  on-arvo   on-arvo:def
  ++  on-leave  on-leave:def
  ++  on-peek
    |=  =path
    ~&  [%peek-path-is path]
    ^-  (unit (unit cage))
    ?+  path
      (on-peek:def path)
    ::
        :: y the y???
        :: Alright, so the y seems to correspond to whether the last piece
        :: of the path is seen here. if we make a %gx scry with /a/b/c, we get
        :: /x/a/b as our path, while with %gy we get /x/a/b/c
        [%y %almanac ~]
      ``noun+!>(alma.state)
    ::
        [%y %calendars ~]
      ``noun+!>((~(get-calendars al alma.state)))
    ::
        [%y %events ~]
      ``noun+!>((~(get-events al alma.state)))
    ::
        [%y %calendars *]
      =/  res  (get-calendar:uc t.t.path)
      ?~  res
        [~ ~]
      ``noun+!>(u.res)
    ::
        [%y %events %specific *]
      =/  res  (get-specific-event:uc t.t.t.path)
      ?~  res
        [~ ~]
      ``noun+!>(u.res)
    ::
        [%y %events %bycal *]
      =/  res  (get-events-bycal:uc t.t.t.path)
      ?~  res
        [~ ~]
      ``noun+!>(u.res)
    ::
        [%y %events %inrange *]
      ~&  [%inrange t.t.t.path]
      =/  res  (get-events-inrange:uc t.t.t.path)
      ?~  res
        [~ ~]
      ``noun+!>(u.res)
    ==
  ++  on-fail   on-fail:def
--
::
::: helper door
::
|_  bowl=bowl:gall
::
++  get-calendar
  |=  =path
  ^-  (unit cal)
  ?.  =((lent path) 1)
    ~
  =/  code=calendar-code  `term`(snag 0 path)
  (~(get-calendar al alma.state) code)
::
++  get-specific-event
  |=  =path
  ^-  (unit event)
  ~&  [%specific-event-path path]
  ?.  =((lent path) 2)
    ~
  =/  =calendar-code  `term`(snag 0 path)
  =/  =event-code  `term`(snag 1 path)
  (~(get-event al alma.state) calendar-code event-code)
::
++  get-events-bycal
  |=  =path
  ^-  (unit (list event))
  ~&  [%bycal-path path]
  ?.  =((lent path) 1)
    ~
  =/  code=calendar-code  `term`(snag 0 path)
  (~(get-events-bycal al alma.state) code)
::
++  get-events-inrange
  |=  =path
  ^-  (unit [(list event) (list projected-event)])
  ?.  =((lent path) 3)
    ~
  =/  =calendar-code  `term`(snag 0 path)
  =/  [start=@da end=@da]
      %+  normalize-period
        (slav %da (snag 1 path))
      (slav %da (snag 2 path))
  (~(get-events-inrange al alma.state) calendar-code start end)
::
::  Handler for '%ucal-action' pokes
::
++  poke-ucal-action
  |=  =action:ucal-store
  ^-  (quip card _state)
  ?-    -.action
      %create-calendar
    =/  input  +.action
    =/  new=cal
      %:  cal                                           :: new calendar
        our.bowl                                        :: ship
        (make-uuid eny.bowl 8)                          :: unique code
        title.input                                     :: title
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    :-  ~
    %=  state
      alma  (~(add-calendar al alma.state) new)
    ==
    ::
      %update-calendar
    =/  input  +.action
    =/  [new-cal=(unit cal) new-alma=almanac]
        (~(update-calendar al alma.state) input now.bowl)
    ?~  new-cal
      ::  nonexistant update
      `state
    =/  rid=resource  (resource-for-calendar calendar-code.u.new-cal)
    =/  ts=to-subscriber:ucal-store  [%update rid %calendar-changed u.new-cal]
    =/  cag=cage  [%ucal-to-subscriber !>(ts)]
    :-  ~[[%give %fact ~[/almanac] cag]]
    state(alma new-alma)
    ::
      %delete-calendar
    =/  code  calendar-code.+.action
    ?<  =(~ (~(get-calendar al alma.state) code))
    ::  produce cards
    ::  kick from /events/bycal/calendar-code
    ::  give fact to /almanac
    =/  cal-update=card
        =/  rid=resource  (resource-for-calendar code)
        =/  removed=to-subscriber:ucal-store  [%update rid %calendar-removed code]
        [%give %fact ~[/almanac] %ucal-to-subscriber !>(removed)]
    :-  ~[cal-update]
    %=  state
      alma  (~(delete-calendar al alma.state) code)
    ==
    ::
      %create-event
    =/  input  +.action
    =/  =about:ucal  [our.bowl now.bowl now.bowl]
    =/  new=event
      %:  event
        %:  event-data
          (make-uuid eny.bowl 8)
          calendar-code.input
          about
          detail.input
          when.input
          invites.input
          %yes  :: organizer is attending own event by default
          tzid.input
        ==
        era.input
      ==
    :: calendar must exist
    ?<  =(~ (~(get-calendar al alma.state) calendar-code.input))
    =/  paths=(list path)  ~[/almanac]
    =/  rid=resource  (resource-for-calendar calendar-code.input)
    =/  ts=to-subscriber:ucal-store  [%update rid %event-added new]
    :-  [%give %fact paths %ucal-to-subscriber !>(ts)]~
    %=  state
      alma  (~(add-event al alma.state) new)
    ==
    ::
      %update-event
    =/  input  +.action
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-event al alma.state) input now.bowl)
    ?~  new-event
      `state  :: nonexistent update
    =/  rid=resource  (resource-for-calendar calendar-code.patch.input)
    =/  ts=to-subscriber:ucal-store  [%update rid %event-changed u.new-event]
    :-
    ~[[%give %fact ~[/almanac] %ucal-to-subscriber !>(ts)]]
    state(alma new-alma)
    ::
      %delete-event
    =/  cal-code  calendar-code.+.action
    =/  event-code  event-code.+.action
    =/  rid=resource  (resource-for-calendar cal-code)
    =/  ts=to-subscriber:ucal-store  [%update rid %event-removed event-code]
    :-
    ~[[%give %fact ~[/almanac] %ucal-to-subscriber !>(ts)]]
    state(alma (~(delete-event al alma.state) event-code cal-code))
    ::
      %change-rsvp
    =/  input  +.action
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-rsvp al alma.state) input)
    ?~  new-event
      `state
    =/  rid=resource  (resource-for-calendar calendar-code.rsvp-change.input)
    =/  ts=to-subscriber:ucal-store  [%update rid %event-changed u.new-event]
    :-
    ~[[%give %fact ~[/almanac] %ucal-to-subscriber !>(ts)]]
    state(alma new-alma)
    ::
      %import-from-ics
    =/  input  +.action
    =/  [cal=calendar events=(list event)]
        %:  vcal-to-ucal
          (calendar-from-file:ucal-parser path.input)
          (make-uuid eny.bowl 8)
          our.bowl
          now.bowl
        ==
    =/  new-alma=almanac
        %-  tail :: only care about state produced in spin, not list
        %^  spin  events
          [(~(add-calendar al alma.state) cal)]
        |=  [e=event alma=almanac]
        ^-  [event almanac]
        [e (~(add-event al alma) e)]
    :-  ~
    %=  state
      alma  new-alma
    ==
  ==
::  +resource-for-calendar: get resource for a given calendar
::
++  resource-for-calendar
  |=  =calendar-code
  ^-  resource
  `resource`[our.bowl `term`calendar-code]
::
:: period of time, properly ordered
::
++  normalize-period
  |=  [a=@da b=@da]
  ^-  [@da @da]
  ?:  (lth b a)
    [b a]
  [a b]
::
++  give
  |*  [=mark =noun]
  ^-  (list card)
  [%give %fact ~ mark !>(noun)]~
::
++  give-single
  |*  [=mark =noun]
  ^-  card
  [%give %fact ~ mark !>(noun)]
--
