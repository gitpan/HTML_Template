#!/usr/bin/perl -w

# this script runs HTML::Template against Dynexus::Template::File in a
# fight to the finish.  The idea is to make sure HTML::Template is at
# least as stable and fast as its predecessor.  It also can be used to
# demonstrate the performance gains using caching.

require "Template.pm";
use Dynexus::Template::File;

# first lets make sure they agree on the output this untimed test
# should also make sure the file is cached - lowering random disk hit
# penalties

sub do_medium_template {
  my $template;
  if ($_[0] eq 'HTML::Template') {
    $template = HTML::Template->new(filename => 'templates/medium.tmpl');
  } elsif ($_[0] eq 'HTML::Template_compat') {
    $template = HTML::Template->new(filename => 'templates/medium.tmpl.old',
                                        vanguard_compatibility_mode => 1
                                       );
  } elsif ($_[0] eq 'HTML::Template_cache') {
    $template = HTML::Template->new(filename => 'templates/medium.tmpl',
                                    cache => 1,
                                   );
  } else {
    $template = Dynexus::Template::File->new('templates/medium.tmpl.old');
  }

  $template->param('ALERT', 'I am alert.');
  $template->param('COMPANY_NAME', "MY NAME IS");
  $template->param('COMPANY_ID', "10001");
  $template->param('OFFICE_ID', "10103214");
  $template->param('NAME', 'SAM I AM');
  $template->param('EMAIL', 'BALH LAG');
  $template->param('ADDRESS', '101011 North Something Something');
  $template->param('CITY', 'NEW York');
  $template->param('STATE', 'NEw York');
  #$template->param('ZIP','10014');
  $template->param('PHONE','212-929-4315');
  $template->param('PHONE2','');
  $template->param('SUBCATEGORIES','kfldjaldsf');
  $template->param('DESCRIPTION',"dsa;kljkldasfjkldsajflkjdsfklfjdsgkfld\nalskdjklajsdlkajfdlkjsfd\n\talksjdklajsfdkljdsf\ndsa;klfjdskfj");
  $template->param('WEBSITE','http://www.assforyou.com/');
  $template->param('INTRANET_URL','http://www.something.com');
  $template->param('REMOVE_BUTTON', "<INPUT TYPE=SUBMIT NAME=command VALUE=\"Remove Office\">");
  $template->param('COMPANY_ADMIN_AREA', "<A HREF=administrator.cgi?office_id=command=manage>Manage Office Administrators</A>");
  $template->param('CASESTUDIES_LIST', "adsfkljdskldszfgfdfdsgdsfgfdshghdmfldkgjfhdskjfhdskjhfkhdsakgagsfjhbvdsaj hsgbf jhfg sajfjdsag ffasfj hfkjhsdkjhdsakjfhkj kjhdsfkjhdskfjhdskjfkjsda kjjsafdkjhds kjds fkj skjh fdskjhfkj kj kjhf kjh sfkjhadsfkj hadskjfhkjhs ajhdsfkj akj fkj kj kj  kkjdsfhk skjhadskfj haskjh fkjsahfkjhsfk ksjfhdkjh sfkjhdskjfhakj shiou weryheuwnjcinuc 3289u4234k 5 i 43iundsinfinafiunai saiufhiudsaf afiuhahfwefna uwhf u auiu uh weiuhfiuh iau huwehiucnaiuncianweciuninc iuaciun iucniunciunweiucniuwnciwe");
  $template->param('NUMBER_OF_CONTACTS', "aksfjdkldsajfkljds");
  $template->param('COUNTRY_SELECTOR', "klajslkjdsafkljds");
  $template->param('LOGO_LINK', "dsfpkjdsfkgljdsfkglj");
  $template->param('PHOTO_LINK', "lsadfjlkfjdsgkljhfgklhasgh");
  return $template->output;
}

my $hResult = do_medium_template('HTML::Template');
my $hoResult = do_medium_template('HTML::Template_compat');
my $tResult = do_medium_template('Template::File');
my $cResult = do_medium_template('HTML::Template_cache');
if (($hResult ne $tResult) || ($hResult ne $hoResult) || ($cResult ne $hoResult)) {
  print "They don't agree on the output for medium.tmpl! Race called off.\n";
}


print "Test 1: Medium.tmpl - 100 iterations.\n\n";

my $t = (times)[0];
for (my $x = 0; $x < 100; $x++) {
  my $hResult = do_medium_template('HTML::Template');
}
my $time = (times)[0] - $t;
my $avg = $time / 100.0;
print "HTML::Template: average time per iteration : $avg seconds\n";

my $t = (times)[0];
for (my $x = 0; $x < 100; $x++) {
  my $hoResult = do_medium_template('HTML::Template_compat');
}
my $time = (times)[0] - $t;
my $avg = $time / 100.0;
print "HTML::Template Compatibility Mode: average time per iteration : $avg seconds\n";


my $t = (times)[0];
for (my $x = 0; $x < 100; $x++) {
  my $cResult = do_medium_template('HTML::Template_cache');
}
my $time = (times)[0] - $t;
my $avg = $time / 100.0;
print "HTML::Template Cache Mode: average time per iteration : $avg seconds\n";


$t = (times)[0];
for (my $x = 0; $x < 100; $x++) {
  my $tResult = do_medium_template('Template::File');
}
$time = (times)[0] - $t;
my $avg = $time / 100.0;
print "Template::File: average time per iteration : $avg seconds\n";
