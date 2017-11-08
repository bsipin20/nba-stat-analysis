#!/usr/bin/perl

package Parser;

use strict;
use warnings;
use Data::Dumper;


# All data was pulled from http://www.basketballgeek.com/data/
# Only 3 seasons of data exist on the site
# Adding more data will require taking the same format data and loading the directory into one data directory that will be specified by user at call time 


#fields based on current data source format 
#if format changes, this hash needs to be appropriately changed
#(field name => col number)

my %bball_geek_fields = (
    "a1" => 0,
    "a2" => 1,
    "a3" => 2,
    "a4" => 3,
    "a5" => 4,
    "h1" => 5,
    "h2" => 6,
    "h3" => 7,
    "h4" => 8,
    "h5" => 9,
    "period" => 10,
    "time" => 11,
    "team" => 12,
    "etype" => 13,
    "assist" => 14,
    "away" => 15,
    "block" => 16,
    "entered" => 17,
    "home" => 18,
    "left" => 19,
    "num" => 20,
    "opponent" => 21,
    "out of" => 22,
    "player" => 23,
    "points" => 24,
    "possession" => 25,
    "reason" => 26,
    "result" => 27,
    "steal" => 28,
    "type" => 29,
    "x" => 30,
    "y" => 31
);



sub get_field_indices 
{
    #able to get field indices based on name type
    my $arguments = shift;

    my @requested_fields = @$arguments;
    my @indices;

    foreach(@requested_fields){
        push @indices, $bball_geek_fields{$_};
    }

    return(\@indices);

}

sub filter_by_team
{
    #current file format yyyymmdd<three letter home team initials><three letter away team initials>
    #example: data/2007-2008.regular_season/20071208.BOSCHI.csv

    my $file = shift;
    my $requested_team = shift;

    #this assumes all file names are the same format which they are for now
    
    my @dirs = split "/",$file;
    my $team_file = $dirs[2];
    
    my $first_team = substr($team_file,9,3);
    my $second_team = substr($team_file,12,3);

    my $answer = 0;

    if($requested_team eq "all"){

        $answer = 1;

    } elsif($first_team eq $requested_team || $second_team eq $requested_team){

        $answer = 1;
    } 

    return($answer);
}


sub filter_by_year
{
    #current file format yyyy-yyyy.regular_season
    #example: data/2007-2008.regular_season/20071208.BOSCHI.csv

   
    my $file = shift;
    my $requested_year = shift;

    my @dir_file = split "/", $file;
    my $year_dir = $dir_file[1];

    my $ending_year = substr($year_dir,5,4);
    my $answer = 0;

    if ($requested_year eq "all"){ 
        $answer = 1;
    } elsif($requested_year eq $ending_year){
        $answer = 1;
    }

    return($answer);

}

sub short {
    #only gets relevant game of season info to be filtered by other functions 
    
    my $path = shift;
    $path =~ s{.*/}{};
    $path = substr($path, 0, 9);
    $path =~ tr/.//d;


    $path;
}

sub read_game_data 
{
    #this returns nothing before file or dir is opened if not appropriate directory of file 
    #works on one file data and returns relevant shot success and location tracking information 

    my $file = shift;
    my $year = shift;
    my $team = shift;
    my $player = shift;
    my $arguments = shift;

    return unless filter_by_year($file,$year);
    return unless filter_by_team($file,$team);

    my $fh;

    open($fh,"<",$file);

    my $indices = get_field_indices($arguments);

    my @needed_info_from_game;

    while(my $line = <$fh>){

        chomp $line;

        my @entered_fields = split ",",$line;

        next unless $entered_fields[$bball_geek_fields{etype}] eq "shot";
        next unless $player eq "all" || $entered_fields[$bball_geek_fields{player}] eq $player;

        next unless defined $entered_fields[$bball_geek_fields{x}]; #there is some data with undefined coordinates. Problem with data source

        my $ref = [@entered_fields[@$indices]];

        push @needed_info_from_game,$ref;

    }

    return @needed_info_from_game ? [short($file),\@needed_info_from_game] : ();

}


sub summarize_season 
{
    # retrieves all results from a season and consolidates to one data structure to be appended to other queried results later
    my ($dir, @subdirs) = @_;
    my %new_hash;

    for (@subdirs) {
        my ($subdir_name, $subdir_structure) = @$_;
                $new_hash{$subdir_name} = $subdir_structure;
    }
    return [short($dir), \%new_hash];
}

sub iterate_over_game_data
{ 

    # walks data directory and delegates the directory consolidating and file reading function results to one data structure
    # file and directory functions are supplied by user. if behavior or analysis changes the resultant actions on the file data can be changed
    
   
    my ($top, $year,$team,$player,$filefunc,$arguments,$dirfunc) = @_;
    my $DIR;

    if (-d $top) {

        my $file;
        unless (opendir $DIR, $top) {
           warn "Couldn’t open season info$!; skipping.\n";
            return;
            }

            my @results;

            while ($file = readdir $DIR) {
                next if $file eq '.' || $file eq '..' || $file eq ".DS_Store";
                my $new_top = "$top/$file";

                push @results, iterate_over_game_data($new_top,$year,$team,$player,$filefunc,$arguments,$dirfunc);
            }


            return $dirfunc->($top, @results);

            } else {

        return $filefunc->($top,$year,$team,$player,$arguments);
    }
}


1;
