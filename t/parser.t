#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";

require Parser;


sub test_filter_by_team

{
    my $file_example_one = "data/2007-2008.regular_season/20071208.BOSCHI.csv";

    my $team_in_game = "BOS";
    my $team_not_in_game = "GSW";
    my $got_first = Parser::filter_by_team($file_example_one,$team_in_game);
    is($got_first,1,"Filter by team worked for true case");

    my $got_second = Nba::Parser::filter_by_team($file_example_one,$team_not_in_game);
    is($got_second,0,"Filter by team worked for false case");

}

sub test_get_field_indices
{
    my $input = ["a1","assist","y"];
    my $expected = [0,14,31];

    my $got = Parser::get_field_indices($input);
    cmp_deeply($got,$expected,"Get field indices works correctly")

}

sub test_filter_by_year
{
    my $example_dir_one = "data/2007-2008.regular_season/20071208.BOSCHI.csv";

    my $year_true_case = "2008";
    my $year_false_case = "2006";

    my $got_first = Parser::filter_by_year($example_dir_one,$year_true_case);
    is($got_first,1,"Filter by year worked for true case");


    my $got_second = Parser::filter_by_year($example_dir_one,$year_false_case);
    is($got_second,0,"Filter by year worked for false case");

}

sub test_short
{
    my $example_dir = "data/2007-2008.regular_season/20071208.BOSCHI.csv";
    my $expected = "20071208";
    my $got = Parser::short($example_dir);
    is($got,$expected,"Short works");

}


sub test_read_game_data
{
    my $file = "data/2007-2008.regular_season/20071208.BOSCHI.csv";
    my $year = "2007";
    my $team = "BOS";
    my $player = "Paul Pierce";
    my $arguments;

    my $got = Parser::read_game_data($file,$year,$team,$player,$arguments);
    cmp_deeply($got,[""],"File Function read game data works")






}

sub main 
{
    require Nba::Parser;

    use Test::More tests => 6;
    use Test::Deep;
    use Data::Dumper;
    
    test_filter_by_team();
    test_filter_by_year();
    test_get_field_indices();
    test_short();
    test_read_game_data();

}

main();


