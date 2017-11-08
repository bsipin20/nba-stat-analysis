#!/usr/bin/perl

use lib "lib";

require Controller;

use strict;
use warnings;



 
#OPTIONS for type of analysis = (shot_type_sorting,shooting_percentages,side_of_court)
# Type side_of_court 
# Definition:
#   Analysis of which side of court the shot was taken
#     left side of court facing away from basket from defenders perspective
#     right side of court facing away from basket from the defenders perspective
#     
#     Percentages by side of court will be displayed over time

# Type shot_type_sorting 
# Definition:
#   Analysis of what type of shot it was based on distance 
#        three_pointer consists of shots taken from 22 to 100 feet from the basket
#        mid_range consists of shots taken from 9 to 22 feet from the basket
#        layup consists of shots taken from 0 to 9 feet from basket 
#        
#        Percentages by shot type will be displayed over time
 
# Type shooting_percentages 
# Definition:
#   Basic analysis of made and missed shot attempts
#   Shooting Percentages are displayed over time


sub main
{
    #Command line interface for NBA shooting statistics
    
    # need in this order (<name of directory where raw data resides>,<year>,<team>,<player>,<type of analysis>)
    # for <year>,<team>,<player> can put "all or specific player"
    # <team> requires team codes, not full team names 
    # For reference:
    # (https://en.wikipedia.org/wiki/Wikipedia:WikiProject_National_Basketball_Association/ _
    # National_Basketball_Association_team_abbreviations) 
    # example: BOS, ATL, DAL equate to Boston Celtics, Atlanta Hawks, Dallas Mavericks
    Controller::request("data","all","BOS","all","shooting_percentages");

}

main();
