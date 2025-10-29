% campus_expert.pl
% Simple Prolog expert system for campus info (SWI-Prolog)
%
% Usage:
%   swipl
%   ?- consult('campus_expert.pl').
%   ?- start.
%
% Type 'help.' for usage inside the system and 'exit.' to quit.
%
% DATA MODELING GUIDELINES
% ------------------------
% building/3 facts use the following shape:
%   building(NameAtom, AreaLabelString, ShortDescriptionString).
%
% - NameAtom: a lowercase atom identifier (no spaces). Use underscores for multi-word names.
%     e.g., library, it_building, admin_office, sports_complex
% - AreaLabelString: a human-friendly label shown to users. Keep it as a single-quoted string.
%     e.g., 'Main Quad', 'Science Block', 'North Wing', 'East Campus'
% - ShortDescriptionString: a brief free-text description in single quotes.
%
% Cross-references (like services, hours, directions) should refer to the NameAtom
% of the building, not the AreaLabelString. For example:
%   service(registration, admin_office, '...').  % refers to the building name (admin_office)
%   hours(library, '8:00 AM - 8:00 PM').         % refers to the building name (library)
%   direction('main gate', library, '...').      % refers to the building name (library)
%
% To add a new building correctly:
%   building(cs_office, 'Science Block, 1st Floor', 'CS Department Office and inquiries').
%   hours(cs_office, '9:00 AM - 4:00 PM').
%   service(student_inquiries, cs_office, 'General student inquiries for CS').

:- initialization(set_prolog_flag(verbose, silent)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sample Knowledge Base
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% building(Name, Area/Location, ShortDescription).
% building(Name, Area/Location, ShortDescription).

building(main_gate, 'Entrance Area', 'Main entrance to the Trincomalee Campus of Eastern University, Sri Lanka.').
building(admin_building, 'Administrative Block', 'Houses the offices of the Rector, Dean, and administrative staff of the Trincomalee Campus.').
building(fas_building, 'Science Complex', 'Main facility for the Faculty of Applied Sciences; includes laboratories, lecture halls, and a smart classroom for blended learning.').
building(fcm_building, 'Commerce & Management Block', 'Building of the Faculty of Commerce and Management; contains classrooms, computer labs, and faculty offices.').
building(fcbs_building, 'Communication & Business Studies Complex', 'Modern building for the Faculty of Communication and Business Studies; project cost around Rs. 821 million, includes administrative and learning facilities.').
building(library, 'Central Library', 'Main library of the Trincomalee Campus; provides study areas, research resources, and digital learning access.').
building(it_center, 'ICT Centre', 'Technology hub supporting students and staff with computer facilities, networking, and e-learning services.').
building(auditorium, 'Main Auditorium', 'Large hall used for academic events, seminars, and cultural programs.').
building(canteen, 'Student Services Area', 'Campus canteen providing food and refreshments for students and staff.').
building(hostel_men, 'Residential Zone - Male Hostel', 'Accommodation for male students with essential amenities and study areas.').
building(hostel_women, 'Residential Zone - Female Hostel', 'Accommodation for female students located near the main teaching blocks.').
building(parking_area, 'Campus Grounds', 'Designated parking spaces for staff, students, and visitors.').
building(sports_complex, 'Sports Grounds', 'Facilities for indoor and outdoor sports including volleyball, cricket, and athletics.').
building(garden_area, 'Campus Green Zone', 'Maintained green area with trees and benches providing a relaxing environment for students.').
building(security_office, 'Entrance Area', 'Campus security control point ensuring safety and access regulation at the main entrance.').


% service(ServiceName, Location, Details).

service(registration, admin_office,
    'Students can complete undergraduate or graduate registration, collect registration forms, and submit required documents at the Admin Office.').

service(id_card, admin_office,
    'The Admin Office issues new student ID cards and handles requests for lost or damaged card replacements.').

service(campus_mail, head_of_department,
    'To send official letters or requests through the campus mail system, students must first obtain approval from the Head of Department (HOD).').

service(exam_apply, head_of_department,
    'Students applying for exams must fill out the exam application form and submit it to the Head of Department (HOD) for verification and approval.').

service(exam_apply_repeat, head_of_department_and_admin_office,
    'For repeat exam applications, students must fill out the repeat exam form, submit it to the Admin Office to check repeat subject details and payment amount, pay the required fees, collect the payment receipt, and then submit both the approved form and payment receipt to the Head of Department (HOD).').

service(gym_apply, sports_council_office,
    'Students who wish to use the gym must fill out a gym application form and submit it to the Sports Council Office for approval.').

service(confirmation_scholarship_letter, head_of_department,
    'To obtain a scholarship confirmation letter, students must collect the request form from the HOD office, fill it out carefully, and submit it back to the department for processing.').


% contact(Name, Role, Phone).
contact('Mrs. Priyanka', 'Head of Student Affairs', '011-2345678').
contact('Mr. Silva', 'Library Manager', '011-9876543').
contact('Dr. Kumar', 'Head of CS Department', '011-5551234').
contact('Security Office', 'Campus Security', '011-9110000').

% hours(Place, OpenHours).
hours(library, '8:00 AM - 8:00 PM').
hours(canteen, '7:30 AM - 6:00 PM').
hours(admin_office, '8:00 AM - 4:00 PM').
hours(cs_lab, '9:00 AM - 3.30 PM').

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

