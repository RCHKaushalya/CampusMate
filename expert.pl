% campus_expert.pl
% Simple Prolog expert system for campus info (SWI-Prolog)
%
% Usage:
%   swipl
%   ?- consult('campus_expert.pl').
%   ?- start.
%
% Type 'help.' for usage inside the system and 'exit.' to quit.

:- initialization(set_prolog_flag(verbose, silent)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample Knowledge Base
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% building(Name, Area/Location, ShortDescription).
building(library, 'Main Quad', 'Central library with study rooms and computers').
building(cs_lab, 'Science Block', 'Computer Science labs (rooms 201-210)').
building(admin_office, 'North Wing', 'Administration and student services').
building(hostel_a, 'East Campus', 'Male hostel A, 3 floors').
building(canteen, 'Main Quad', 'Cafeteria serving meals and snacks').
building(sports_complex, 'South Field', 'Indoor courts and gym').

% service(ServiceName, Location, Details).
service(registration, admin_office, 'Undergraduate/Graduate registration and forms').
service(id_card, admin_office, 'ID card issuance and replacements').
service(canteen_menu, canteen, 'Open breakfast and lunch. Cash and card accepted').
service(clubs_office, admin_office, 'Information about student clubs and societies').

% contact(Name, Role, Phone).
contact('Mrs. Priyanka', 'Head of Student Affairs', '011-2345678').
contact('Mr. Silva', 'Library Manager', '011-9876543').
contact('Dr. Kumar', 'Head of CS Department', '011-5551234').
contact('Security Office', 'Campus Security', '011-9110000').

% hours(Place, OpenHours).
hours(library, '8:00 AM - 8:00 PM').
hours(canteen, '7:30 AM - 6:00 PM').
hours(admin_office, '9:00 AM - 5:00 PM').
hours(cs_lab, '9:00 AM - 9:00 PM').

% direction(From, To, Steps).
% Short illustration directions; expand with real campus routes.
direction('main gate', library, 'Walk straight 200m, library on your left').
direction(library, cs_lab, 'Exit library, turn right, walk 3 minutes to Science Block').
direction(admin_office, canteen, 'Go down the stairs, cross the quad, canteen ahead').

% club(ClubName, Location, Contact).
club('Music Club', admin_office, 'Clubs Office').
club('Chess Club', sports_complex, 'Sports Office').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inference rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% where_is(+Place, -Location).
where_is(Place, Location) :-
    building(Place, Location, _).

% what_service_at(+Location, -Service, -Details).
what_service_at(Location, Service, Details) :-
    service(Service, Location, Details).

% who_contact_for(+Topic, -Person, -Role, -Phone).
who_contact_for(Topic, Person, Role, Phone) :-
    ( contact(Person, Role, Phone), sub_atom(Role, _, _, _, Topic)
    ; contact(Person, Role, Phone), sub_atom(Person, _, _, _, Topic)
    ).

% find_contact_by_role(+RoleKeyword, -Name, -Phone).
find_contact_by_role(RoleKeyword, Name, Phone) :-
    contact(Name, Role, Phone),
    sub_atom(Role, _, _, _, RoleKeyword).

% open_hours(+Place, -Hours).
open_hours(Place, Hours) :-
    hours(Place, Hours).

% get_direction(+From, +To, -Steps).
get_direction(From, To, Steps) :-
    direction(From, To, Steps).

% clubs_list(-Club, -Location, -Contact).
clubs_list(Club, Location, Contact) :-
    club(Club, Location, Contact).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple keyword-based interpreter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% start/0: launch the interactive loop
start :-
    writeln('--- Campus Expert System (Prolog) ---'),
    writeln("Type a question like: 'where is library?', 'who do I contact for id card', 'hours library', 'services at admin_office'"),
    writeln("Type 'help.' for more commands."), nl,
    loop.

% loop/0: read user input repeatedly
loop :-
    prompt1('> '),
    read_line_to_string(user_input, Raw),
    ( Raw == end_of_file -> writeln('Goodbye.'), !, halt
    ; string_lower(Raw, InputLower),
      ( InputLower = "" -> loop
      ; interpret(InputLower)
      ),
      loop
    ).

% interpret(+InputString)
interpret(Input) :-
    ( sub_string(Input, _, _, _, "help") ->
        print_help
    ; sub_string(Input, _, _, _, "exit") ->
        writeln('Exiting. Goodbye.'), halt
    ; sub_string(Input, _, _, _, "where") ->
        interpret_where(Input)
    ; sub_string(Input, _, _, _, "who") ;
      sub_string(Input, _, _, _, "contact") ->
        interpret_contact(Input)
    ; sub_string(Input, _, _, _, "hours") ;
      sub_string(Input, _, _, _, "open") ->
        interpret_hours(Input)
    ; sub_string(Input, _, _, _, "service") ;
      sub_string(Input, _, _, _, "services") ;
      sub_string(Input, _, _, _, "at") ->
        interpret_services(Input)
    ; sub_string(Input, _, _, _, "direction") ;
      sub_string(Input, _, _, _, "how to get") ->
        interpret_directions(Input)
    ; sub_string(Input, _, _, _, "club") ;
      sub_string(Input, _, _, _, "clubs") ->
        interpret_clubs(Input)
    ; % fallback: try to answer specific keywords
      interpret_fallback(Input)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpreters for types of queries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

interpret_where(Input) :-
    % try to find a building mentioned in input
    find_building_in_input(Input, Place),
    ( where_is(Place, Location) ->
        format('~w is located at ~w.~n', [Place, Location])
    ; format('I do not have location information for "~w".~n', [Place])
    ).

interpret_contact(Input) :-
    % Look for keywords like id card, library, security, student affairs
    ( sub_string(Input, _, _, _, "id card") ->
        ( what_service_at(admin_office, Service, Details) ->
            writeln('ID card service:'),
            format('  Service: ~w~n  Details: ~w~n  Contact: ', [Service, Details]),
            ( find_contact_by_role('Student Affairs', Name, Phone) -> format('~w (~w)~n', [Name, Phone]); writeln('No contact found.') )
        ; writeln('No ID card service info found.')
        )
    ; sub_string(Input, _, _, _, "library") ->
        ( find_contact_by_role('Library', Name, Phone) -> format('Library contact: ~w (~w)~n', [Name, Phone])
        ; writeln('No library contact found.')
        )
    ; % generic contact search - try to find a contact name or role keyword in the input
      split_string(Input, " ", "?,.!'", Tokens),
      find_contact_keyword_in_tokens(Tokens, Name, Role, Phone) ->
        format('Contact: ~w (~w) - ~w~n', [Name, Role, Phone])
    ; writeln('Sorry, I could not find a contact for that query.')
    ).

interpret_hours(Input) :-
    find_building_in_input(Input, Place),
    ( open_hours(Place, Hours) ->
        format('Opening hours for ~w: ~w~n', [Place, Hours])
    ; writeln('No opening hours found for that place.')
    ).

interpret_services(Input) :-
    find_building_in_input(Input, Place),
    ( what_service_at(Place, Service, Details) ->
        format('Service at ~w: ~w - ~w~n', [Place, Service, Details])
    ; writeln('No services found for that location.')
    ).

interpret_directions(Input) :-
    % expects "from X to Y" or "to Y" or "how to get to Y"
    ( sub_string(Input, _, _, _, "to ") ->
        sub_string_after(Input, "to ", ToStr),
        normalize_name(ToStr, To),
        ( get_direction(_, To, Steps) ->
            format('Directions to ~w: ~w~n', [To, Steps])
        ; format('No stored directions to ~w.~n', [To])
        )
    ; writeln('Please ask like "how to get to library" or "direction to cs_lab".')
    ).

interpret_clubs(_) :-
    writeln('Registered student clubs:'),
    forall(clubs_list(C, Loc, Contact),
           format('  ~w (Location: ~w, Contact: ~w)~n', [C, Loc, Contact])
          ).

interpret_fallback(Input) :-
    % try to find a building and give brief info
    ( find_building_in_input(Input, Place),
      building(Place, Loc, Desc) ->
        format('~w (~w): ~w~n', [Place, Loc, Desc])
    ; writeln('Sorry, I did not understand. Type "help." for query examples.')
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

print_help :-
    writeln('Commands / queries you can try:'),
    writeln('  where is library?'),
    writeln('  who do I contact for id card?'),
    writeln('  hours library'),
    writeln('  services at admin_office'),
    writeln('  how to get to cs_lab'),
    writeln('  list clubs'),
    writeln('  help'),
    writeln('  exit.').

% Normalize a string to a lowercase atom without extra spaces and punctuation
normalize_name(Str, NameAtom) :-
    string_lower(Str, S1),
    split_string(S1, " ", " ,.?'", Pieces),
    atomic_list_concat(Pieces, '_', A),
    atom_string(NameAtom, A).

% find_building_in_input(+InputString, -PlaceAtom)
% tries to match known building names appearing in InputString
find_building_in_input(Input, Place) :-
    building(B, _, _),
    atom_string(B, Bs),
    string_lower(Bs, Bsl),
    sub_string(Input, _, _, _, Bsl),
    Place = B, !.

% find_contact_keyword_in_tokens(+Tokens, -Name, -Role, -Phone)
find_contact_keyword_in_tokens(Tokens, Name, Role, Phone) :-
    member(Token, Tokens),
    string_length(Token, L), L > 2, % skip very short tokens
    string_lower(Token, Tk),
    ( find_contact_by_role(Tk, Name, Phone) ->
        contact(Name, Role, Phone)
    ; contact(Name, Role, Phone), sub_string(Name, _, _, _, Tk)
    ).

% helper: substring after a pattern
sub_string_after(String, Pattern, After) :-
    sub_string(String, _, Len, AfterLen, Pattern),
    Start is (string_length(String) - Len - AfterLen) + string_length(Pattern),
    sub_string(String, Start, AfterLen, 0, After).

% helpful predicate to stop via query
exit :- halt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
