package Asr::Controller::Admin;

use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';

use Asr::Controller::Utils qw(generate_hal_links validate_paging_params parse_sort_params);
use Asr::Schema::Result::User;
use Mojo::JSON qw(encode_json);
use Mojolicious::Validator;

sub root {
   my $self = shift;
   my $result = Data::HAL->new();
   my $links = [
      {relation => 'self', templated => 0, href => '/admin'},
      {relation => 'users', templated => 1, href => '/admin/users', params => '{?size,index,sort}'},
      {relation => 'roles', templated => 1, href => '/admin/roles', params => '{?size,index,sort}'},
      {relation => 'tags', templated => 1, href => '/admin/tags', params => '{?size,index,sort}'}
   ];

   $result->links(&generate_hal_links($self, $links));

   $self->render(text => $result->as_json, format => 'haljson');
}

1;
