use Mojo::Base;
use Test::More;
use Test::Mojo;

plan tests => 113;

my $t = Test::Mojo->new('Asr');
my $rs = $t->app->schema->resultset('Role');
my $test_role_name = 'testrole';
my $test_role_description = 'Test Role';
my $dbrebase = `carton exec -- sqitch rebase -y db:pg://test:test\@localhost/test > /dev/null`;

if ($dbrebase) {
   BAIL_OUT($dbrebase);
}

ok my $default_role = $rs->find(
   {name => 'admin'},
   {key => 'role_name_key'}
), 'admin role found';
ok $default_role->id eq 0, 'admin role id is correct';
is $default_role->name, 'admin', 'admin role name is correct';
is $default_role->description, 'Administrator Role', 'admin role description is correct';

$t->get_ok('/api/admin/roles')
   ->status_is(401, 'got correct status code')
   ->json_has('/timestamp', 'got timestamp value')
   ->json_is('/status' => '401', 'got correct status value')
   ->json_is('/message' => 'Authentication required', 'got correct message value');

$t->post_ok('/auth/login', json => {username => 'admin', password => 'secret'})
   ->status_is(204, 'got correct status code')
   ->header_like('Set-Cookie' => qr/^mojolicious=.*$/, 'got session cookie')
   ->content_is('', 'got correct content value');

$t->post_ok('/api/admin/roles', json => {name => $test_role_name, invalid => 'invalid'})
   ->status_is(400, 'got correct status code')
   ->json_has('/timestamp', 'got timestamp value')
   ->json_is('/status' => '400', 'got correct status value')
   ->json_is('/message' => "Invalid field 'invalid'.", 'got correct message value');

$t->post_ok('/api/admin/roles', json => {name => $test_role_name, description => $test_role_description})
   ->status_is(201, 'got correct status code')
   # ->json_has('/_links/self/href', 'has a self link')
   # ->json_is('/_links/self/templated' => Mojo::JSON::false, 'self link is not templated')
   ->json_has('/_embedded/roles/id', 'test role id exists')
   ->json_is('/_embedded/roles/name' => $test_role_name, 'test role name is correct')
   ->json_is('/_embedded/roles/description' => $test_role_description, 'test role description is correct');

$t->get_ok('/api/admin/roles')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/roles')
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/api/admin/roles?sort=id.desc')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/roles/0')
   ->json_has('/_embedded/roles/0/id')
   ->json_is('/_embedded/roles/0/name' => $test_role_name)
   ->json_is('/_embedded/roles/0/description' => $test_role_description)
   ->json_has('/_embedded/roles/1')
   ->json_is('/_embedded/roles/1/id' => $default_role->id)
   ->json_is('/_embedded/roles/1/name' => $default_role->name)
   ->json_is('/_embedded/roles/1/description' => $default_role->description)
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/api/admin/roles?sort=name.desc')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/roles/0')
   ->json_has('/_embedded/roles/0/id')
   ->json_is('/_embedded/roles/0/name' => $test_role_name)
   ->json_is('/_embedded/roles/0/description' => $test_role_description)
   ->json_has('/_embedded/roles/1')
   ->json_is('/_embedded/roles/1/id' => $default_role->id)
   ->json_is('/_embedded/roles/1/name' => $default_role->name)
   ->json_is('/_embedded/roles/1/description' => $default_role->description)
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/api/admin/roles?sort=invalid.desc')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

$t->get_ok('/api/admin/roles?sort=name.desc&size=1&index=1')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/roles')
   ->json_has('/_embedded/roles/id')
   ->json_is('/_embedded/roles/name' => $test_role_name)
   ->json_is('/_embedded/roles/description' => $test_role_description)
   ->json_has('/page/index')
   ->json_is('/page/index' => 1)
   ->json_has('/page/size')
   ->json_is('/page/size' => 1)
   ->json_has('/page/totalItems')
   ->json_is('/page/totalItems' => 2);

$t->get_ok('/api/admin/roles?sort=name.desc&size=1&index=2')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/roles')
   ->json_is('/_embedded/roles/id' => $default_role->id)
   ->json_is('/_embedded/roles/name' => $default_role->name)
   ->json_is('/_embedded/roles/description' => $default_role->description)
   ->json_has('/page/index')
   ->json_is('/page/index' => 2)
   ->json_has('/page/size')
   ->json_is('/page/size' => 1)
   ->json_has('/page/totalItems')
   ->json_is('/page/totalItems' => 2);

$t->get_ok('/api/admin/roles?size=invalid')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

$t->get_ok('/api/admin/roles?index=invalid')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

done_testing;
