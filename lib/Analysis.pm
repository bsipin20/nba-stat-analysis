#!/usr/bin/perl

package Analysis;

use strict;
use warnings;

# result, points, x, y
# center of hoop (25, 5.25)

# NBA scouting relies on trending shooter data 
# Analyzing Shot location and success can be helpful when examining teams tendencies on offense
# Tracking these metrics over time would be helpful in predicting current and future behavior of a team
# This module implements analysis of shot type analysis and behavior of teams or players based on user input
#

sub find_month 
{
    # finds month from game data file name
    # example: 20071208.BOSCHI.csv


    my $string = shift;

    my $year = substr($string,0,4);
    my $month = substr($string,4,2);

    my $new_format = "$year-$month";

    return($new_format);

}

sub sum
{
    #sums array ref
    my ($arrayref) = shift;
    my $result = 0;

    foreach(@$arrayref){
        $result = $result + $_;



    }
    return($result);

}

sub calculate_distance_from_hoop
{
    #calculates distance from hoop using Pythagorean theorem
    #receives x and y coordinate of shot and compares to distance from hoop, 
    #listed from http://www.basketballgeek.com/data/
#

    my ($x_coord_of_shot,$y_coord_of_shot) = @_;

    my $x_coord_of_hoop= 25;
    my $y_coord_of_hoop = 5.25;

    if($x_coord_of_shot eq ""){
        print "$x_coord_of_shot,$y_coord_of_shot\n";
    }
    my $dist = sqrt( ( $x_coord_of_shot - $x_coord_of_hoop)**2 + ($y_coord_of_shot - $y_coord_of_hoop)**2);

    my $rounded = sprintf("%.1f", $dist);

    return($rounded);
}


sub shooting_percentages
{

    # organizes data to be analyzed later
    # denotes if shot attempt was made or not and lists along with date
    
    my $game_data_set = shift;
    my $game = shift;
   
    my $made = 0;
    my $fg_attempts = 0;

    my @results;

    foreach(@$game_data_set){

        if ($_->[0] eq "made"){
            push @results,, [find_month($game),$_->[1],"shot_attempt"];

        } else {
            push @results, [find_month($game),$_->[1],"shot_attempt"];


        }
    }

    return(@results);
}

sub count_which_side_of_hoop
{
    #finds out which side of hoop each shot was taken from in a game set data
    #<=25 is the left facing away from the basket 
    #>25 is the right side facing away from the basket
    
    my $game_data_set = shift;
    my $game = shift;
   
    my @results;

    for (my $i=0; $i < scalar @$game_data_set; $i++) {

        if($game_data_set->[$i]->[3] <= 25 ){
            push @results,[find_month($game),$game_data_set->[$i]->[1],"left side of court"];


        } else {
            push @results,[find_month($game),$game_data_set->[$i]->[1],"right side of court"];

        }
    }

    return(@results);
}


sub determine_shot_type
{
    #determines shot type by location
    # the important and interesting part is to separate mid range from layup,location 
    # is one way to objectively do that
    my $distance_from_basket = shift;
    my $shot_def = {
        three_pointer => [22,100],
        mid_range => [9,22],
        layup => [0,9]
    };



    my $type;

    foreach(keys %$shot_def){
        my $min_range = $shot_def->{$_}->[0];
        my $max_range = $shot_def->{$_}->[1];

        if($distance_from_basket >= $min_range  && $distance_from_basket <= $max_range){

            $type = $_;
        }
    }

    return($type);

}


sub shot_type_sorting
{
    # organizes data to be analyzed later by a summary function
    # tags certain data based on shot type (determined by location with sub determine_shot_type
    
    my $game_day_data = shift;
    my $game = shift;

    my @shot_type_bin;


   foreach(@$game_day_data){

        my $dist = calculate_distance_from_hoop($_->[2],$_->[3]);
        my $shot_tag = determine_shot_type($dist);
        my $array_ref = [find_month($game),$_->[1],$shot_tag];
        push @shot_type_bin,$array_ref;
    }

    return(@shot_type_bin);
 
}


sub print_out_summary
{
    #basic visual output that prints out to terminal
    my $month = shift;
    my $results = shift;

    
    foreach(keys %$results){

        my $sum = sum($results->{$_});
        my $total = @{$results->{$_}};
        my $percentage = ($sum/$total)* 100;

        print "$month\t$_\t$sum\t$total\t$percentage\n";

    }
    return(1);
}

sub summarize_results
{

    #every results data structure follows [month,result,tag]
    #sorts by month then summarizes each month by printing to the terminal
    
    my $results = shift;

    my $sorted_results = [ sort { $a->[0] cmp $b->[0] } @$results];

    my %results_bin;

    my $prev_month = $sorted_results->[0]->[0];

    print "month\tshot type\tmade\ttotal\tpercentage\n";

    foreach(@$sorted_results){

        my $make_or_miss = ($_->[1] ne '') ? 1 : 0;

        if($prev_month ne $_->[0]){

            
            print_out_summary($prev_month,\%results_bin);

            $prev_month = $_->[0];


        } elsif($results_bin{$_->[2]}){


            push @{ $results_bin{$_->[2]} }, $make_or_miss;


        } else {

            $results_bin{$_->[2]} = [$make_or_miss];


        }

    }
    return($sorted_results);

}

sub compute_analysis 
{
    #given a game data set
    #supply analysis subroutine to every game and store results in an array to be summarized later
    
    my $data_set = shift;
    my $analysis_func_ref = shift;
    my $criteria = shift;

    my @calculations = @_;
    
    my @over_time_shot;

    foreach my $season (keys %$data_set){

        foreach my $game (keys %{$data_set->{$season}}){

            my $game_day_data = $data_set->{$season}->{$game};
            my @result = $analysis_func_ref->($game_day_data,$game);

            push @over_time_shot,@result;

        }
    }

    return(\@over_time_shot);

}


1;
