package HTML::Template;

use strict;
use vars qw( $VERSION %CACHE );
$VERSION = 0.02;

=head1 NAME

HTML::Template - Perl module to use HTML Templates from CGI scripts

=head1 SYNOPSIS

First you make a template - this is just a normal HTML file with a few
extra tags, the simplest being <TMPL_VAR>

For example, test.tmpl:

  <HTML>
  <HEAD><TITLE>Test Template</TITLE>
  <BODY>
  My Home Directory is <TMPL_VAR NAME=HOME>
  <P>
  My Path is set to <TMPL_VAR NAME=PATH>
  </BODY>
  </HTML>
  

Now create a small CGI program:

  use HTML::Template;

  # open the html template
  my $template = HTML::Template->new(filename => 'test.tmpl');

  # fill in some parameters
  $template->param('HOME', $ENV{HOME});
  $template->param('PATH', $ENV{PATH});

  # send the obligatory Content-Type
  print "Content-Type: text/html\n\n";

  # print the template
  print $template->output;

If all is well in the universe this should show something like this in
your browser when visiting the CGI:

My Home Directory is /home/some/directory
My Path is set to /bin;/usr/bin

=head1 DESCRIPTION

This module attempts make using HTML templates simple and natural.  It
extends standard HTML with a few new HTML-esque tags - <TMPL_VAR> and
<TMPL_LOOP>.  The file written with HTML and these new tags is called
a template.  It is usually saved separate from your script - possibly
even created by someone else!  Using this module you fill in the
values for the variables and loops declared in the template.  This
allows you to seperate design - the HTML - from the data, which you
generate in the Perl script.

This module is licenced under the GPL.  See the LICENCE section
below for more details.

=head1 MOTIVATION

It is true that there are a number of packages out there to do HTML
templates.  On the one hand you have things like HTML::Embperl which
allows you freely mix Perl with HTML.  On the other hand lie
home-grown variable substitution solutions.  Hopefully the module can
find a place between the two.

One advantage of this module over a full HTML::Embperl-esque solution
is that it enforces an important divide - design and programming.  By
limiting the programmer to just using simple variables and loops in
the HTML, the template remains accessible to designers and other
non-perl people.  The use of HTML-esque syntax goes further to make
the format understandable to others.  In the future this similarity
could be used to extend existing HTML editors/analyzers to support
HTML::Template.

An advantage of this module over home-grown tag-replacement schemes is
the support for loops.  In my work I am often called on to produce
tables of data in html.  Producing them using simplistic HTML
templates results in CGIs containing lots of HTML since the HTML
itself cannot represent loops.  The introduction of loop statements in
the HTML simplifies this situation considerably.  The designer can
layout a single row and the programmer can fill it in as many times as
necessary - all they must agree on is the parameter names.

For all that, I think the best thing about this module is that it does
just one thing and it does it quickly and carefully.  It doesn't try
to replace Perl and HTML, it just augments them to interact a little
better.  And it's pretty fast.

=head1 The Tags

Note: even though these tags look like HTML they are a little
different in a couple of ways.  First, they must appear entirely on
one line.  Second, they're allowed to "break the rules".  Something
like:

   <IMG SRC="<TMPL_VAR NAME=IMAGE_SRC>">

is not really valid HTML, but it is a perfectly valid use and will
work as planned.

=head2 <TMPL_VAR NAME="PARAMETER_NAME">

The <TMPL_VAR> tag is very simple.  For each <TMPL_VAR> tag in the
template you call $template->param("PARAMETER_NAME", "VALUE").  When
the template is output the <TMPL_VAR> is replaced with the VALUE text
you specified.  If you don't set a parameter it just gets skipped in
the output.

The "NAME=" in the tag is now optional, although for exensibility's
sake I recommend using it.  Example - "<TMPL_VAR PARAMETER_NAME>" is
now acceptable.

=head2 <TMPL_LOOP NAME="LOOP_NAME"> </TMPL_LOOP>

The <TMPL_LOOP> tag is a bit more complicated.  The <TMPL_LOOP> tag
allows you to delimit a section of text and give it a name.  Inside
the <TMPL_LOOP> you place <TMPL_VAR>s.  Now you pass to param() a list
(an array ref) of parameter assignments (hash refs) - the loop
iterates over this list and produces output from the text block for
each pass.  Unset parameters are skipped.  Here's an example:

   In the template:

   <TMPL_LOOP NAME=EMPLOYEE_INFO>
         Name: <TMPL_VAR NAME=NAME> <P>
         Job: <TMPL_VAR NAME=JOB> <P>
        <P>
   </TMPL_LOOP>


   In the script:

   $template->param('EMPLOYEE_INFO', 
                    [ 
                     { name => 'Sam', job => 'programmer' },
                     { name => 'Steve', job => 'soda jerk' },
                    ],
                   );
   print $template->output();

  
   The output:

   Name: Sam <P>
   Job: programmer <P>
   <P>
   Name: Steve <P>
   Job: soda jerk <P>
   <P>

As you can see above the <TMPL_LOOP> takes a list of variable
assignments and then iterates over the loop body producing output.

<TMPL_LOOP>s within <TMPL_LOOP>s are fine and work as you would
expect.  If the syntax for the param() call has you stumped, here's an
example of a param call with one nested loop:

  $template->param('ROW',[
                          { name => 'Bobby',
                            nicknames => [
                                          { name => 'the big bad wolf' }, 
                                          { name => 'He-Man' },
                                         ],
                          },
                         ],
                  );

Basically, each <TMPL_LOOP> gets an array reference.  Inside the array
are any number of hash references.  These hashes contain the
name=>value pairs for a single pass over the loop template.  It is
probably in your best interest to build these up programatically, but
that is up to you!

The "NAME=" in the tag is now optional, although for exensibility's
sake I recommend using it.  Example - "<TMPL_LOOP LOOP_NAME>" is
now acceptable.

=cut

=head1 Methods

=head2 new()

Call new() to create a new Template object:

  my $template = HTML::Template->new( filename => 'file.tmpl', 
                                      option => 'value' 
                                    );

You must call new() with at least one name => value pair specifing how
to access the template text.  You can use "filename => 'file.tmpl'" to
specify a filename to be opened as the template.  Alternately you can
use:

  my $t = HTML::Template->new( scalarref => $ref_to_template_text, 
                               option => 'value' 
                             );


and

  my $t = HTML::Template->new( arrayref => $ref_to_array_of_lines , 
                               option => 'value' 
                             );


These initialize the template from in-memory resources.  These are
mostly of use internally for the module - in almost every case you'll
want to use the filename parameter.  If you're worried about all the
disk access from a template file just use the cache option detailed
below.

The three new() calling methods can also be accessed as below, if you
prefer.

  my $t = HTML::Template->new_file('file.tmpl', option => 'value');

  my $t = HTML::Template->new_scalar_ref($ref_to_template_text, 
                                        option => 'value');

  my $t = HTML::Template->new_array_ref($ref_to_array_of_lines, 
                                       option => 'value');

And as a final option, for those that might prefer it, you can call new as:

  my $t = HTML::Template->new_file(type => 'filename', 
                                   source => 'file.tmpl');

Which works for all three of the source types.

You can modify the Template object's behavior with new.  These options
are available:

=over 4

=item *

debug - if set to 1 the module will write debugging information to
STDOUT.  Defaults to 0.

=item *

die_on_bad_params - if set to 0 the module will let you call
$template->param('param_name', 'value') even if 'param_name' doesn't
exist in the template body.  Be careful with this one - I can't think
of any situations where this shouldn't be an error.  Defaults to 1.

=item *

cache - if set to 1 the module will cache in memory the parsing of
templates based on the filename parameter and modification date of the
file.  This only applies to templates opened with the filename
parameter specified, not the scalarref or arrayref templates.  Note
that different new() parameter settings do not cause a cache refresh,
only a change in the modification time of the template will trigger a
cache refresh.  For most usages this is fine.  My simplistic testing
shows that setting cache to 1 yields a 50% performance increase, more
if you use large <TMPL_LOOP>s.  Cache defaults to 0.

=item *

vanguard_compatibility_mode - if set to 1 the module will expect to
see <TMPL_VAR>s that look like %NAME% instead of the standard syntax.
If you're not at Vanguard Media trying to use an old format template
don't worry about this one.  Defaults to 0.

=back 4

=cut

# open a new template and return an object handle
sub new {
  my $pkg = shift;
  my %hash;
  for (my $x = 0; $x <= $#_; $x += 2) { $hash{lc($_[$x])} = $_[($x + 1)]; }
  my $self = bless(\%hash, $pkg);

  # set default parameters
  exists($self->{debug}) || ($self->{debug} = 0);
  exists($self->{cache}) || ($self->{cache} = 0);
  exists($self->{die_on_bad_param}) || ($self->{die_on_bad_param} = 1);
  exists($self->{vanguard_compatibility_mode}) 
    || ($self->{vanguard_compatibility_mode} = 0);

  $self->{param} = {};

  # handle the "type" "source" parameter format
  if (exists($self->{type})) {
    (exists($self->{source})) || (die "HTML::Template->new() called with 'type' parameter set, but no 'source'!");
    $self->{$self->{type}} = $self->{source};
  }

  # check for syntax errors:
  my $source_count = 0;
  (exists($self->{filename})) && ($source_count++);
  (exists($self->{arrayRef})) && ($source_count++);
  (exists($self->{scalarRef})) && ($source_count++);
  if ($source_count > 1) {
    die "HTML::Template->new called with multiple template sources specified!  A valid call to new() has at most one filename => 'file' OR one scalarRef => \\\$scalar OR one arrayRef = \\\@array.";
  }

  # initialize data structures
  $self->_init;
  
  return $self;
}

# a few shortcuts, of possible use...
sub new_file {
  my $pkg = shift; return $pkg->new('filename', @_);
}
sub new_array_ref {
  my $pkg = shift; return $pkg->new('arrayref', @_);
}
sub new_scalar_ref {
  my $pkg = shift; return $pkg->new('scalarref', @_);
}

# initilizes all the object data structures.  Also handles global
# cacheing of template parse data.
sub _init {
  my $self = shift;

  # look in the cache to see if we have a cached copy of this template
  if ($self->{cache} && (exists($self->{filename})) && 
      (exists($CACHE{$self->{filename}}))) {
    (-r $self->{filename}) || die("HTML::Template : template file $self->{filename} does not exist or is unreadable.");    
    
    # get the modification time
    my $mtime = (stat($self->{filename}))[9];
    ($self->{debug}) && (print "Modify time of $mtime for " . $self->{filename} . "\n");
    
    # if the modification time has changed remove the cache entry and
    # re-call $self->_init
    if ($mtime != $CACHE{$self->{filename}}{mtime}) {
      delete($CACHE{$self->{filename}});
      return $self->_init;
    } else {
      # else, use the cached values instead of calling _init_template
      # and _pre_parse.
      $self->{template} = ${$CACHE{$self->{filename}}{template}};
      $self->{param_map} = ${$CACHE{$self->{filename}}{param_map}};
      $self->{loop_heap} = ${$CACHE{$self->{filename}}{loop_heap}};
      return $self;
    }
  }

  # init the template and parse data
  $self->_init_template;
  $self->_pre_parse;
  
  # if we're caching, cache the results of _init_template and _pre_parse
  # for future use
  if ($self->{cache} && (exists($self->{filename}))) {
    my $mtime = (stat($self->{filename}))[9];
    $CACHE{$self->{filename}}{mtime} = $mtime;
    $CACHE{$self->{filename}}{template} = \$self->{template};
    $CACHE{$self->{filename}}{param_map} = \$self->{param_map};
    $CACHE{$self->{filename}}{loop_heap} = \$self->{loop_heap};
  }
  
  return $self;
}

# initialize the template buffer
sub _init_template {
  my $self = shift;

  if (exists($self->{filename})) {    
    # check filename param and try to open
    (-r $self->{filename}) || die("HTML::Template : template file $self->{filename} does not exist or is unreadable.");

    # open the file
    open(TEMPLATE, $self->{filename}) || die("Unable to open file $self->{filename}");

    # read into the array
    my @templateArray = <TEMPLATE>;
    close(TEMPLATE);

    # copy in the ref
    $self->{template} = \@templateArray;

  } elsif (exists($self->{scalarref})) {
    # split it into an array by line, preserving \n's on all but the
    # last line
    my @templateArray = split("\n", ${$self->{scalarref}});
    foreach my $line (@templateArray) { $line .= "\n"; }

    # copy in the ref
    $self->{template} = \@templateArray;

  } elsif (exists($self->{arrayref})) {
    # if we have an array ref, just copy it
    $self->{template} = $self->{arrayref};

  } else {
    die("HTML::Template : Need to call new with filename, scalarref or arrayref parameter specified.");
  }
  return $self;
}

# _pre_parse sifts through a template building up the param_map and
# loop_heap structures
#
# The param_map stores the names and location of TMPL_VAR parameters.
# When output runs it can then just use the param_map to find
# out where to make its substitutions.
#
# The loop_heap is a little more complicated.  It stores both the
# location and the Template object for each TMPL_LOOP encountered.
#
# The end result is a Template object that is fully ready for
# output().
sub _pre_parse {
  my $self = shift;
  
  ($self->{debug}) && (print "\nIn pre_parse:\n\n");

  $self->{param_map} = {};
  $self->{loop_heap} = {};
  
  for (my $line_number = 0; $line_number <= $#{$self->{template}}; $line_number++) {
    my $line = $self->{template}[$line_number];
    my $done_with_line = 0;

    # handle the old vanguard format
    if ($self->{vanguard_compatibility_mode}) {
      if ($line =~ s/[%]{1}([\w]+)[%]{1}/<TMPL_VAR NAME=$1>/g) {
        $self->{template}[$line_number] = $line;
      }
    }

    while(!$done_with_line) {
      # Look for a loop start
      if ($line =~ /(.*?)<[tT][mM][pP][lL]_[lL][oO][oO][pP]\s+([nN][aA][mM][eE]\s*=)?\s*"?(\w+)"?\s*>(.*)/g) {
        my $preloop = $1;
        my $name = lc $3;
        my $chunk = $4;
        ($self->{debug}) && (print "$line_number : saw loop $name\n");
        
        # find the end of the loop
        my ($loop_body, $leftover, $pos);
        for ($pos = $line_number; $pos <= $#{$self->{template}}; $pos++) {
          if ($pos != $line_number) {
            $chunk .= $self->{template}[$pos];
          }
          ($loop_body, $leftover) = $self->_extractLoop(\$chunk);
          defined($loop_body) && last;
        }
        (defined($loop_body)) || die("HTML::Template : Problem looking for matching </TMPL_LOOP> for <TMPL_LOOP NAME=${name}> : Could not find one!");
        ($self->{debug}) && (print "Loop $name body: \n$loop_body\n\n");
        
        # store the results
        push(@{$self->{loop_heap}{$name}{spot}}, $line_number);
        push(@{$self->{loop_heap}{$name}{template_object}}, HTML::Template->new( scalarref => \$loop_body, debug => $self->{debug} ));
        
        # if we've got a multiline match we'll need to undef the
        # lines we gobbled for the loop body.
        if ($pos > $line_number) {
          foreach (my $x = $line_number + 1; $x <= $pos; $x++) {
              $self->{template}[$x] = undef;
            }
          }
        
        # now reform $line to remove loop body
        $line = $preloop . ' <TMPL_LOOP NAME=' . $name . ' PLACEHOLDER> ' . $leftover;
          # donate back the changes
        $self->{template}[$line_number] = $line;
        next;          
      }
      
      my @names = ($line =~ /<[tT][mM][pP][lL]_[vV][aA][rR]\s+(?:[nN][aA][mM][eE]\s*=)?\s*"?(\w+)"?\s*>/gx);
      foreach my $name (@names) {
        $name = lc($name);
        (exists($self->{param_map}{$name})) || ($self->{param_map}{$name} = []);
        push(@{$self->{param_map}{$name}}, $line_number);
        
        # set their value initially to undef
        $self->{param}{$name} = undef;
        
        ($self->{debug}) && (print "$line_number : saw $name\n");
      }

      # all done
      $done_with_line = 1;
    }
  }

  return $self;
}

# returns ($loop_body, $leftover) given a chunk following directly
# after a <TMPL_LOOP NAME=BLAH> tag.  Returns undef if the block does
# not contain a valid loop body.
sub _extractLoop {
  my ($self, $chunkRef) = @_;

  # try each possible loop body available
  my ($loop_body, $leftover);
  while (${$chunkRef} =~ /(.+)<\/[Tt][Mm][Pp][Ll]_[Ll][Oo][Oo][Pp]>(.*)/gs) {
    $loop_body = $1;
    $leftover = $2;

    # if the loop body has an equal number of loop starts and stops
    # then it's a valid loop body!
    my (@loop_starts) = ($loop_body =~ /(<[tT][mM][pP][lL]_[Ll][Oo][Oo][Pp])/g);
    my (@loop_stops) = ($loop_body =~ /<(\/[tT][mM][pP][lL]_[Ll][Oo][Oo][Pp])/g);
    if ($#loop_starts == $#loop_stops) {
      # found it!
      return ($loop_body, $leftover);
    }
  }
  return undef;
}

=head2 param

param() can be called in three ways


1) To return a list of parameters in the template : 

   my @parameter_names = $self->param();
   

2) To return the value set to a param : 
 
   my $value = $self->param('PARAM');

   
3) To set the value of a parameter :

      # For simple TMPL_VARs:
      $self->param('PARAM', 'value');

      # And TMPL_LOOPs:
      $self->param('LOOP_PARAM', 
                   [ 
                    { PARAM => VALUE_FOR_FIRST_PASS, ... }, 
                    { PARAM => VALUE_FOR_SECOND_PASS, ... } 
                    ...
                   ]
                  );

=cut

sub param {
  my ($self, $param, $value) = @_;
  
  if (!defined($param)) {
    # return a list of parameters in this template
    return (keys(%{$self->{param}}));
  } elsif (!defined($value)) {
    $param = lc($param);
    # check for parameter existence 
    if ($self->{die_on_bad_param} && !exists($self->{param_map}{$param})
                                    && !exists($self->{loop_heap}{$param})) {
      die("HTML::Template : Attempt to set nonexistent parameter $param");
    }

    # return the value set to a param
    return($self->{param}{$param});
  } else {
    $param = lc($param);
    # check that this param exists in the template
    if ($self->{die_on_bad_param} && !exists($self->{param_map}{$param})
                                    && !exists($self->{loop_heap}{$param})) {
      die("HTML::Template : Attempt to set nonexistent parameter $param");
    }

    # set the parameter and return $self

    # copy in contents of ARRAY refs to prevent confusion - 
    # thanks Richard!
    if ( ref($value) eq 'ARRAY' ) {
      $self->{param}{$param} = [@{$value}];
    } else {
      $self->{param}{$param} = $value;
    }
    return $self;
  }

  die("This can't be happening.");
}

=head2 clear_params()

Sets all the parameters to undef.  Useful internally, if nowhere else!

=cut

sub clear_params {
  my $self = shift;
  foreach my $name ($self->param()) {
    $self->{param}{$name} = undef;
  }

}

=head2 output()

output() returns the final result of the template.  In most situations you'll want to print this, like:

   print $template->output();

When output is called each occurance of <TMPL_VAR NAME=name> is
replaced with the value assigned to "name" via param().  If a named
parameter is unset it is simply replaced with ''.  <TMPL_LOOPS> are
evaluated once per parameter set, accumlating output on each pass.

Calling output() is garaunteed not to change the state of the
Template object, in case you were wondering.  This property is mostly
important for the internal implementation of loops.

=cut

sub output {
  my $self = shift;
  ($self->{debug}) && (print "\nIn output\n\n");

  # keep a hash of lines changed in the replace loop
  my %templateChanges;

  # kick off the search and replace loop
  # works by following the param_map for each named param
  foreach my $name (keys %{$self->{param}}) {
    my $value = $self->{param}{$name};
    ($self->{debug} && !defined($value)) && (print "parameter $name not set at output()\n");
    (defined($value)) || ($value = '');
    
    # visit each spot on the map and do a replace into templateChanges
    foreach my $spot (@{$self->{param_map}{$name}}) {
      defined($templateChanges{$spot}) 
        || ($templateChanges{$spot} = $self->{template}[$spot]);
      my $found = ($templateChanges{$spot} =~ s/<tmpl_var\s+(name\s*=)?\s*"?${name}"?\s*>/$value/sgi);
      ($self->{debug}) && (print "matched $name $found times at $spot\n");
    }
  }

  # handle the loops
  foreach my $name (keys %{$self->{loop_heap}}) {
    my $valueARef = $self->{param}{$name};
    ($self->{debug} && !defined($valueARef)) && (print "parameter $name not set at output()\n");
    (defined($valueARef)) || ($valueARef = undef);
    
    # visit each spot on the map and do a looping output() on the loop
    # object.  Insert the result into the spot just like a var
    # interpolation
    for( my $x = 0; $x <= $#{$self->{loop_heap}{$name}{spot}}; $x++) {
      my $spot = $self->{loop_heap}{$name}{spot}[$x];
      my $tobj = $self->{loop_heap}{$name}{template_object}[$x];
      defined($templateChanges{$spot}) 
        || ($templateChanges{$spot} = $self->{template}[$spot]);
      my $loop_output = '';
      foreach my $valueSetRef (@{$valueARef}) {
        # set the parameters for this iteration
        foreach my $name (keys %{$valueSetRef}) {
          $tobj->param($name, $valueSetRef->{$name});
        }
        # accumulate output and clear params
        $loop_output .= $tobj->output;
        $tobj->clear_params();
      }
      my $found = ($templateChanges{$spot} =~ s/<tmpl_loop\s+name\s*=\s*"?${name}"?\s*PLACEHOLDER>/$loop_output/i);
      ($self->{debug}) && (print "matched loop $name $found times at $spot\n");
    }
  }

  # all done - concat up the resulting arrays, skipping undef'd lines
  my $result = "";
  for (my $x = 0; $x <= $#{$self->{template}}; $x++) {
    if (exists($templateChanges{$x})) {
      $result .= $templateChanges{$x};
    } elsif (defined($self->{template}[$x])) {
      $result .= $self->{template}[$x];
    }
  }
  return $result;
}


1;
__END__

=head1 BUGS

The <TMPL_LOOP> </TMPL_LOOP> matching code was difficult to write and
debug.  I think you can assume from that that its not perfect.  If you
have trouble with the module detecting the closing </TMPL_LOOP>, move
it to its own line.  If it's still crapping out, try moving the
<TMPL_LOOP NAME="name"> to its own line as well.

Other than that I am aware of no bugs - if you find one, email me
(sam@tregar.com) with full details, including the VERSION of the
module and a test script / test template demonstrating the problem.

=head1 CREDITS

This module was the brain child of my boss, Jesse Erlbaum
(jesse@vm.com) here at Vanguard Media.  The most original idea in this
module - the <TMPL_LOOP> - was entirely his.

Fixes and Bug Reports have been generously provided by:

   Richard Chen


Thanks!

=head1 AUTHOR

Sam Tregar, sam@tregar.com

=head1 LICENCE

HTML::Template : A module for using HTML Templates with Perl

Copyright (C) 1999 Sam Tregar (sam@tregar.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA

=cut
