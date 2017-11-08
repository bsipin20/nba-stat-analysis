#!/usr/bin/perl


package Controller;

use Parser;
use Analysis;

use strict;
use warnings;

my %profile_type = (

    # this could be an argument later but specifies which columns to pull from raw data source
    
    get_location_data  => ["result","points","x","y"]

);

	
sub retrieve_appropriate_data 
{
    #receives request from user and gets data by walking over data directory of games partioned by season
    
    my ($dir,$year,$team,$player,$request_type) = @_;

    my $retrieved_data = Parser::iterate_over_game_data($dir,
                                           $year,
                                           $team,
                                           $player,
                                           \&Parser::read_game_data,$profile_type{$request_type},
                                           \&Parser::summarize_season);

    my $game_data = $retrieved_data->[1];

    return($game_data);
}


sub request
{
    # processes user request and applies appropriate analysis to queried data set and prints result
    
    my ($dir,$year,$team,$player,$request) = @_;

    #receives request, analyzed based on type of request, summarize and prints results to terminal

    my $analysis_type = {

        shot_type_sorting => \&Analysis::shot_type_sorting,
        shooting_percentages => \&Analysis::shooting_percentages,
        side_of_court => \&Analysis::count_which_side_of_hoop

    };

    my $data = retrieve_appropriate_data($dir,$year,$team,$player,"get_location_data");

    my $results = Analysis::compute_analysis($data,$analysis_type->{$request});

    Analysis::summarize_results($results);


}




1;
