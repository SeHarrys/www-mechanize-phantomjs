#!perl -w
use strict;
use Test::More;
use WWW::Mechanize::WebDriver;
use lib 'inc', '../inc';
use Test::HTTP::LocalServer;

my $mech = eval { WWW::Mechanize::WebDriver->new( 
    autodie => 1,
    launch_exe => 'phantomjs-versions\phantomjs-1.9.2-windows\phantomjs',
    launch_arg => ['ghostdriver\src\main.js' ],
    port => 8910, # XXX
    #log => [qw[debug]],
    #on_event => 1,
)};

if (! $mech) {
    plan skip_all => "Couldn't connect to PhantomJS: $@";
    exit
} else {
    plan tests => 13;
};

$mech->get_local('50-form2.html');
is $mech->current_form, undef, "At start, we have no current form";
$mech->form_number(2);
my $button = $mech->selector('#btn_ok', single => 1);
isa_ok $button, 'MozRepl::RemoteObject::Instance', "The button image";
ok $mech->submit, 'Sent the page';
is $mech->current_form, undef, "After a submit, we have no current form";

$mech->get_local('50-form2.html');
$mech->form_id('snd2');
ok $mech->current_form, "We can find a form by its id";
is $mech->current_form->{id}, 'snd2', "We can find a form by its id";
$mech->field('id', 99);
is $mech->xpath('.//*[@name="id"]',
    node => $mech->current_form, 
    single => 1)->{value}, 99,
    "We set values in the correct form";

$mech->get_local('50-form2.html');
$mech->form_with_fields('r1','r2');
ok $mech->current_form, "We can find a form by its contained input fields";

$mech->get_local('50-form2.html');
$mech->form_name('snd');
ok $mech->current_form, "We can find a form by its name";
is $mech->current_form->{name}, 'snd', "We can find a form by its name";

$mech->get_local('50-form2.html');
is $mech->current_form, undef, "On a new ->get, we have no current form";

$mech->get_local('50-form2.html');
$mech->form_with_fields('comment');
ok $mech->current_form, "We can find a form by its contained textarea fields";

$mech->get_local('50-form2.html');
$mech->form_with_fields('quickcomment');
ok $mech->current_form, "We can find a form by its contained select fields";