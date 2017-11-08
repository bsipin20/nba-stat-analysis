#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";
use Data::Dumper;
#Test Parser;

sub get_test_season_data
{
    my $example_set = 
        [   
            [
              'made',
              '2',
              '25',
              '6'
            ],
            [
              'made',
              '2',
              '11',
              '19'
            ],
            [
              'made',
              '2',
              '25',
              '6'
            ],
        ];
        return($example_set);
}

sub test_shooting_percentages
{
    my $test_data = get_test_season_data();
    my $expected = [

        ["2009-10",2,"shot_attempt"],
        ["2009-10",2,"shot_attempt"],
        ["2009-10",2,"shot_attempt"]

    ];

    my @got =  Analysis::shooting_percentages($test_data,"20091004");

    is_deeply(\@got,$expected,"Shooting Percentages calculator works");

}

sub test_side_of_hoop
{
    my $test_data = get_test_season_data();

    my $expected = [

        ["2009-10",2,"left side of court"],
        ["2009-10",2,"left side of court"],
        ["2009-10",2,"left side of court"]

    ];


    my @got =  Analysis::count_which_side_of_hoop($test_data,"20091004");
    
    cmp_deeply(\@got,$expected,"Side of Hoop calculator works");



}

sub test_distance_from_hoop
{
    my $got =  Analysis::calculate_distance_from_hoop(25,19);
    
    is($got,13.8,"Test Distance From Hoop");


}

sub test_handle_dates
{

    my $got = Analysis::find_month("20091004");
    is($got,"2009-10","Found correct month");

}

sub test_determine_shot_type
{
    my $got_one = Analysis::determine_shot_type(8);
    is($got_one,"layup","Shot Type Close Range successfully detected");

    my $got_two = Analysis::determine_shot_type(15);
    is($got_two,"mid_range","Shot Type Mid Range successfully detected");

    my $got_three = Analysis::determine_shot_type(23);
    is($got_three ,"three_pointer","Shot Type Long Range successfully detected");

}
sub test_sum
{
    my $test_data = [0,1,1,1,0];
    my $got = Analysis::sum($test_data);
    is($got,3,"Sum sub works");



}
sub test_shot_type_sorting 
{
    my $game_day_data = get_test_season_data();

    #simple example testing 2 shots at 0 distance from hoop and 1 shot very far that would be considered a three pointer by any standard
    #should be all lay ups
    my $example_set = 
        [   
            [
              'made',
              '2',
              '25',
              '5.25'
            ],
            [
              'made',
              '2',
              '25',
              '5.25'
            ],
            [
              'made',
              '2',
              '100',
              '5'
            ],
        ];

    my @got = Analysis::shot_type_sorting($example_set,"20091004");
    my $expected = [
        ["2009-10",2,"layup"],
        ["2009-10",2,"layup"],
        ["2009-10",2,"three_pointer"]
    ];

    cmp_deeply(\@got,$expected,"Shot type sorting works");

 

}
sub test_summarize_results
{
    my $unsorted_results_ex = [
        ["2010-12",2,"layup"],
        ["2006-10",2,"layup"],
        ["2014-10",2,"three_pointer"]
    ];

    my $expected = [
        ["2006-10",2,"layup"],
        ["2010-12",2,"layup"],
        ["2014-10",2,"three_pointer"]
    ];

    my $got = Analysis::summarize_results($unsorted_results_ex);

    cmp_deeply($got,$expected,"Summarize results properly sorts");


}

sub main 
{

    use Test::More tests => 10;
    use Test::Deep;
 
    require Analysis;

    test_shooting_percentages();

    test_side_of_hoop();

    test_sum();
    test_distance_from_hoop();
    test_handle_dates();
    test_determine_shot_type();
    test_shot_type_sorting();
    test_summarize_results();


}

main();


