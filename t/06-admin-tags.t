use Mojo::Base;
use Test::More;
use Test::Mojo;

plan tests => 113;

my $t = Test::Mojo->new('Asr');
my $rs = $t->app->schema->resultset('Tag');
my $test_tag_name = 'testtag';
my $test_tag_info = 'Test Tag';
my $dbrebase = `carton exec -- sqitch rebase -y db:pg://test:test\@localhost/test > /dev/null`;

if ($dbrebase) {
   BAIL_OUT($dbrebase);
}

ok my $default_tag = $rs->find(
   {name => 'default'},
   {key => 'tag_name_key'}
), 'default tag found';
ok $default_tag->id eq 0, 'default tag id is correct';
is $default_tag->name, 'default', 'default tag name is correct';
is $default_tag->info, 'All data will be tagged with this unless specified otherwise.', 'default tag info is correct';

$t->get_ok('/admin/tags')
   ->status_is(401, 'got correct status code')
   ->json_has('/timestamp', 'got timestamp value')
   ->json_is('/status' => '401', 'got correct status value')
   ->json_is('/message' => 'Authentication required', 'got correct message value');

$t->post_ok('/auth/login', json => {username => 'admin', password => 'secret'})
   ->status_is(204, 'got correct status code')
   ->header_like('Set-Cookie' => qr/^mojolicious=.*$/, 'got session cookie')
   ->content_is('', 'got correct content value');

$t->post_ok('/admin/tags', json => {name => $test_role_name, invalid => 'invalid'})
   ->status_is(400, 'got correct status code')
   ->json_has('/timestamp', 'got timestamp value')
   ->json_is('/status' => '400', 'got correct status value')
   ->json_is('/message' => "Invalid field 'invalid'.", 'got correct message value');


$t->post_ok('/admin/tags', json => {name => $test_tag_name, info => $test_tag_info})
   ->status_is(201, 'got correct status code')
   # ->json_has('/_links/self/href', 'has a self link')
   # ->json_is('/_links/self/templated' => Mojo::JSON::false, 'self link is not templated')
   ->json_has('/_embedded/tags/id', 'test tag id exists')
   ->json_is('/_embedded/tags/name' => $test_tag_name, 'test tag name is correct')
   ->json_is('/_embedded/tags/info' => $test_tag_info, 'test tag info is correct');

$t->get_ok('/admin/tags')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/tags')
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/admin/tags?sort=id.desc')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/tags/0')
   ->json_has('/_embedded/tags/0/id')
   ->json_is('/_embedded/tags/0/name' => $test_tag_name)
   ->json_is('/_embedded/tags/0/info' => $test_tag_info)
   ->json_has('/_embedded/tags/1')
   ->json_is('/_embedded/tags/1/id' => $default_tag->id)
   ->json_is('/_embedded/tags/1/name' => $default_tag->name)
   ->json_is('/_embedded/tags/1/info' => $default_tag->info)
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/admin/tags?sort=name.desc')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/tags/0')
   ->json_has('/_embedded/tags/0/id')
   ->json_is('/_embedded/tags/0/name' => $test_tag_name)
   ->json_is('/_embedded/tags/0/info' => $test_tag_info)
   ->json_has('/_embedded/tags/1')
   ->json_is('/_embedded/tags/1/id' => $default_tag->id)
   ->json_is('/_embedded/tags/1/name' => $default_tag->name)
   ->json_is('/_embedded/tags/1/info' => $default_tag->info)
   ->json_has('/page/index')
   ->json_like('/page/index', qr/^\d+$/)
   ->json_has('/page/size')
   ->json_like('/page/size', qr/^\d+$/)
   ->json_has('/page/totalItems')
   ->json_like('/page/totalItems', qr/^\d+$/);

$t->get_ok('/admin/tags?sort=invalid.desc')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

$t->get_ok('/admin/tags?sort=name.desc&size=1&index=1')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/tags')
   ->json_has('/_embedded/tags/id')
   ->json_is('/_embedded/tags/name' => $test_tag_name)
   ->json_is('/_embedded/tags/info' => $test_tag_info)
   ->json_has('/page/index')
   ->json_is('/page/index' => 1)
   ->json_has('/page/size')
   ->json_is('/page/size' => 1)
   ->json_has('/page/totalItems')
   ->json_is('/page/totalItems' => 2);

$t->get_ok('/admin/tags?sort=name.desc&size=1&index=2')
   ->status_is(200, 'got correct status code')
   ->json_has('/_links/self/href')
   ->json_is('/_links/self/templated' => Mojo::JSON::true)
   # ->json_has('/_links/search/href')
   # ->json_is('/_links/search/templated' => Mojo::JSON::false)
   ->json_has('/_embedded/tags')
   ->json_is('/_embedded/tags/id' => $default_tag->id)
   ->json_is('/_embedded/tags/name' => $default_tag->name)
   ->json_is('/_embedded/tags/info' => $default_tag->info)
   ->json_has('/page/index')
   ->json_is('/page/index' => 2)
   ->json_has('/page/size')
   ->json_is('/page/size' => 1)
   ->json_has('/page/totalItems')
   ->json_is('/page/totalItems' => 2);

$t->get_ok('/admin/tags?size=invalid')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

$t->get_ok('/admin/tags?index=invalid')
   ->status_is(400, 'should get invalid request due to invalid column')
   ->json_has('/status')
   ->json_has('/message')
   ->json_has('/timestamp');

done_testing;
