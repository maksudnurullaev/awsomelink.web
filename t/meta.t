use Test::More;
use Test::Mojo;
use Utils;

my $t = Test::Mojo->new('AWSomeLink');

# HTML/XML
$t->get_ok('/')->status_is(200);
done_testing();
Utils::sync_meta("/home/ubuntu/projects/awsomelink.web/FILES/a63dc0da");
