package Asr::Controller::Admin::Users;

use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';

use Asr::Controller::Utils qw(generate_hal_links validate_paging_params parse_sort_params);
use Asr::Schema::Result::User;
use Mojo::JSON qw(encode_json);

sub list {
   my $self = shift;
   my ($page_size, $page_index, $rs, $order);
   my $result = Data::HAL->new();
   my $links = [
      {relation => 'self', templated => 1, href => '/admin/users', params => '{?size,index,sort}'}
   ];

   &validate_paging_params($self, keys %{$self->schema->source('User')->columns_info});

   #The failed validation method requires Mojolicious 6.0
   if ($self->validation->has_error) {
      $self->stash(
         message => "The following parameters failed validation: @{$self->validation->failed}"
      );
      return $self->render(template => 'client_error', status => 400)
   }

   $page_size = $self->validation->param('size') // $self->config->{page_size};
   $page_index = $self->validation->param('index') // $self->config->{page_index};
   $order = &parse_sort_params($self);

   $rs = $self->schema->resultset('User')->search(undef, {
      rows => $page_size,
      page => $page_index,
      order_by => $order,
   });

   $result->resource({
      page => {
         index => $rs->pager->current_page,
         size => $rs->pager->entries_per_page,
         totalItems => $rs->pager->total_entries + 0E0,
      }
   });

   $result->links(&generate_hal_links($self, $links));

   my @embedded = map {
      my $links = [{
         relation => 'self',
         href => "/admin/tags/${\$_->id}",
         templated => 0,
      }];
      Data::HAL->new(
         resource => $_->TO_JSON,
         relation => 'tags',
         links => &generate_hal_links($self, $links)
      );
   } $rs->all;

   $result->embedded(\@embedded);

   $self->render(text => $result->as_json, format => 'haljson');
}

sub list {
   my $self = shift;
   my ($page_size, $page_index, $rs, $order);
   my $result = Data::HAL->new;
   my $links = [
      {relation => 'self', templated => 1, href => '/api/admin/users', params => '{?size,index,sort}'},
      {relation => 'search', templated => 0, href => '/api/admin/users/search'}
   ];

   &validate_paging_params($self, keys %{$self->schema->source('User')->columns_info});

   #The failed validation method requires Mojolicious 6.0
   if ($self->validation->has_error) {
      $self->stash(
         message => "The following parameters failed validation: @{$self->validation->failed}"
      );
      return $self->render(template => 'client_error', status => 400)
   }

   $page_size = $self->validation->param('size') // $self->config->{page_size};
   $page_index = $self->validation->param('index') // $self->config->{page_index};
   $order = &parse_sort_params($self);

   $rs = $self->schema->resultset('User')->search(
      undef, {
         rows => $page_size,
         page => $page_index,
         order_by => $order,
      },
   );

   $result->resource({
      page => {
         index => $rs->pager->current_page,
         size => $rs->pager->entries_per_page,
         totalItems => $rs->pager->total_entries + 0E0,
      }
   });

   $result->links(&generate_hal_links($self, $links));

   my @embedded = map {
      my $links = [{
         relation => 'self',
         href => "/api/admin/users/${\$_->id}",
         templated => 0,
      }];
      Data::HAL->new(
         resource => $_->TO_JSON,
         relation => 'users',
         links => &generate_hal_links($self, $links)
      );
   } $rs->all;

   $result->embedded(\@embedded);

   $self->render(text => $result->as_json, format => 'haljson');
}

sub user {
   my $self = shift;
   my $links = [
      {relation => 'self', templated => 1, href => '/api/admin/users/:id'},
   ];
   my $result;
   &_sanitize_params($self);

   #The failed validation method requires Mojolicious 6.0
   $self->stash(message => "The following parameters failed validation: @{$self->validation->failed}");

   return $self->render(template => 'client_error', status => 400)
      if $self->validation->has_error;

   $result = &_get_data($self, 'remote_user', 'users');

   $result->links(&generate_hal_links($self, $links));

   $self->render(text => $result->as_json, format => 'haljson');
}

1;
