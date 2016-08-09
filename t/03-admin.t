use Mojo::Base;
use Test::More;
use Test::Mojo;

plan tests => 23;

my $t = Test::Mojo->new('Asr');
my $schema = $t->app->schema;
my $test_login = 'testadmin';
my $test_password = '$PBKDF2$HMACSHA1:10000:V1vkyg==$KYm4g9zuezKKOQ2lrIapwBqoqH0=';
my $dbrebase = `carton exec -- sqitch rebase -y db:pg://test:test\@localhost/test > /dev/null`;

if ($dbrebase) {
   BAIL_OUT($dbrebase);
}

$schema->resultset('User')->create({
      login => $test_login,
      password => $test_password
});

ok my $dadmin = $schema->resultset('User')->find(
   {login => 'admin'},
   {key => 'user_login_key'}
), 'default admin user exist';
ok $dadmin->id eq 0, 'default admin has uid 0';
is $dadmin->login, 'admin', 'got a login';
isnt $dadmin->password, undef, 'got a password';

$t->get_ok('/admin')
   ->status_is(401, 'got correct status code')
   ->json_has('/timestamp', 'got timestamp value')
   ->json_is('/status' => '401', 'got correct status value')
   ->json_is('/message' => 'Authentication required', 'got correct message value');

$t->post_ok('/auth/login', json => {username => $dadmin->login, password => 'secret'})
   ->status_is(204, 'got correct status code')
   ->header_like('Set-Cookie' => qr/^mojolicious=.*$/, 'got session cookie')
   ->content_is('', 'got correct content value');

$t->get_ok('/admin')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::false)
   ->json_has('/_links/roles/href')
   ->json_is('/_links/roles/templated' => Mojo::JSON::true)
   ->json_has('/_links/users/href')
   ->json_is('/_links/users/templated' => Mojo::JSON::true)
   ->json_has('/_links/tags/href')
   ->json_is('/_links/tags/templated' => Mojo::JSON::true);

done_testing;
