use Mojo::Base;
use Test::More;
use Test::Mojo;

plan tests => 113;

my $t = Test::Mojo->new('Asr');
my $rs = $t->app->schema->resultset('User');
my $test_user_login = 'testadmin';
my $test_user_name = 'Test User';
my $dbrebase = `carton exec -- sqitch rebase -y db:pg://test:test\@localhost/test > /dev/null`;

if ($dbrebase) {
   BAIL_OUT($dbrebase);
}

ok my $default_user = $rs->find(
   {login => 'admin'},
   {key => 'user_login_key'}
), 'admin user found';
ok $default_user->id eq 0, 'admin user id is correct';
is $default_user->login, 'admin', "admin user login is correct";
isnt $default_user->password, undef, 'admin user password is defined';

$t->get_ok('/admin/users')
   ->status_is(401, 'got correct status code')
   ->json_has('/timestamp', 'got timestamp value')
   ->json_is('/status' => '401', 'got correct status value')
   ->json_is('/message' => 'Authentication required', 'got correct message value');

$t->post_ok('/auth/login', json => {username => $default_user->login, password => 'secret'})
   ->status_is(204, 'got correct status code')
   ->header_like('Set-Cookie' => qr/^mojolicious=.*$/, 'got session cookie')
   ->content_is('', 'got correct content value');

$t->post_ok('/admin/users', json => {login => $test_user_login, invalid => 'invalid'})
   ->status_is(400, 'got correct status code')
   ->json_has('/timestamp', 'got timestamp value')
   ->json_is('/status' => '400', 'got correct status value')
   ->json_is('/message' => "Invalid field 'invalid'.", 'got correct message value');

$t->post_ok('/admin/users', json => {
      login => $test_user_login,
      name => $test_user_name,
      password => 'testsecret'
   })
   ->status_is(201, 'got correct status code')
   # ->json_has('/_links/self/href', 'has a self link')
   # ->json_is('/_links/self/templated' => Mojo::JSON::false, 'self link is not templated')
   ->json_has('/_embedded/users/id', 'test user id exists')
   ->json_is('/_embedded/users/login' => $test_user_login, 'test user login is correct')
   ->json_is('/_embedded/users/name' => $test_user_name, 'test role name is correct');

$t->get_ok('/admin/users')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/users')
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/admin/users?sort=id.desc')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/users/0')
   ->json_has('/_embedded/users/0/id')
   ->json_is('/_embedded/users/0/login' => $test_user_login)
   ->json_is('/_embedded/users/0/name' => $test_user_name)
   ->json_has('/_embedded/users/1')
   ->json_is('/_embedded/users/1/id' => $default_user->id)
   ->json_is('/_embedded/users/1/login' => $default_user->login)
   ->json_is('/_embedded/users/1/name' => $default_user->name)
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/admin/users?sort=login.desc')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/users/0')
   ->json_has('/_embedded/users/0/id')
   ->json_is('/_embedded/users/0/login' => $test_user_login)
   ->json_is('/_embedded/users/0/name' => $test_user_name)
   ->json_has('/_embedded/users/1')
   ->json_is('/_embedded/users/1/id' => $default_user->id)
   ->json_is('/_embedded/users/1/login' => $default_user->login)
   ->json_is('/_embedded/users/1/name' => $default_user->name)
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/admin/users?sort=invalid.desc')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

$t->get_ok('/admin/users?sort=login.desc&size=1&index=1')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/users')
   ->json_has('/_embedded/users/id')
   ->json_is('/_embedded/users/login' => $test_user_login)
   ->json_is('/_embedded/users/name' => $test_user_name)
   ->json_has('/page/index')
   ->json_is('/page/index' => 1)
   ->json_has('/page/size')
   ->json_is('/page/size' => 1)
   ->json_has('/page/totalItems')
   ->json_is('/page/totalItems' => 2);

$t->get_ok('/admin/users?sort=login.desc&size=1&index=2')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/users')
   ->json_is('/_embedded/users/id' => $default_user->id)
   ->json_is('/_embedded/users/login' => $default_user->login)
   ->json_is('/_embedded/users/name' => $default_user->name)
   ->json_has('/page/index')
   ->json_is('/page/index' => 2)
   ->json_has('/page/size')
   ->json_is('/page/size' => 1)
   ->json_has('/page/totalItems')
   ->json_is('/page/totalItems' => 2);

$t->get_ok('/admin/users?size=invalid')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

$t->get_ok('/admin/users?index=invalid')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

done_testing;
