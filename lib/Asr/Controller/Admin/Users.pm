package Asr::Controller::Admin::Users;

use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';

use Mojolicious::Routes::Pattern;
use TryCatch;
use Asr::Controller::Utils qw(generate_hal_links validate_paging_params parse_sort_params);

sub list {
   my $self = shift;
   my ($page_size, $page_index, $rs, $order);
   my $result = Data::HAL->new();
   my $links = [
      {relation => 'self', templated => 1, href => '/api/admin/users', params => '{?size,index,sort}'}
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

sub read {
   my $self = shift;
   my $result = Data::HAL->new();
   my $row;

   try {
      $row = $self->schema->resultset('User')->find($self->param('id'));

      if (!$row) {
         return $self->reply->not_found;
      }
   } catch (DBIx::Error $err) {
      $self->app->log->error($err->message);
      return $self->reply->exception;
   }

   # my $pattern = Mojolicious::Routes::Pattern->new('/admin/users/:id');
   # say $pattern->render({id => $self->param('id')});

   $result->embedded([
      Data::HAL->new({
         resource => $row->TO_JSON,
         relation => 'users',
         links => [
            Data::HAL::Link->new({
               relation => 'self',
               template => 0,
               href => "/api/admin/users/${\$row->id}"
            })
         ]
      })
   ]);

   $self->render(text => $result->as_json, format => 'haljson');
}

sub create {
   my $self = shift;
   my $row;
   my $result = Data::HAL->new();
   my $rs = $self->schema->resultset('User');
   my $role_rs = $self->schema->resultset('UserRole');

   try {
      $row = $rs->create($self->req->json);
      $role_rs->create({
         user_id => $row->id,
         role_id => 0
      });
   } catch (DBIx::Error::UniqueViolation $err) {
      $self->app->log->warn($err->message);
      return $self
         ->stash(message => 'Duplicated value.')
         ->render(template => 'client_error', status => 409);
   } catch (DBIx::Class::Exception $err) {
      if ($err =~ /No such column '(.+)'/) {
         $self->app->log->warn($err);
         return $self
            ->stash(message => "Invalid field '$1'.")
            ->render(template => 'client_error', status => 400);
      } else {
         return $self->reply->exception($err);
      }
   }

   $result->embedded([
      Data::HAL->new({
         resource => $row->TO_JSON,
         relation => 'users',
         links => [
            Data::HAL::Link->new({
               relation => 'self',
               template => 0,
               href => "/api/admin/users/${\$row->id}"
            })
         ]
      })
   ]);

   $self->render(text => $result->as_json, format => 'haljson', status => 201);
}

sub update {
   my $self = shift;
   my $row;
   my $result = Data::HAL->new();
   my $rs = $self->schema->resultset('User');

   try {
      $row = $rs->find($self->param('id'));

      if ($row) {
         $row->set_inflated_columns($self->req->json);

         # Explicitly use the accessor so the password gets hashed
         if ($self->req->json->{password}) {
            $row->password($self->req->json->{password});
         }

         $row->update;
      } else {
         return $self->reply->not_found;
      }
   } catch (DBIx::Error::UniqueViolation $err) {
      $self->app->log->warn($err->message);
      return $self
         ->stash(message => 'Duplicated value.')
         ->render(template => 'client_error', status => 409);
   } catch (DBIx::Class::Exception $err) {
      if ($err =~ /No such column '(.+)'/) {
         $self->app->log->warn($err);
         return $self
            ->stash(message => "Invalid field '$1'.")
            ->render(template => 'client_error', status => 400);
      } else {
         return $self->reply->exception($err);
      }
   }

   $result->embedded([
      Data::HAL->new({
         resource => $row->TO_JSON,
         relation => 'users',
         links => [
            Data::HAL::Link->new({
               relation => 'self',
               template => 0,
               href => "/api/admin/users/${\$row->id}"
            })
         ]
      })
   ]);

   $self->render(text => $result->as_json, format => 'haljson', status => 204);
}

sub delete {
   my $self = shift;
   my $row;
   my $rs = $self->schema->resultset('User');

   try {
      $row = $rs->find($self->param('id'));

      if ($row) {
         $row->delete;
         $self->render(data => '', status => 204);
      } else {
         return $self->reply->not_found;
      }
   } catch (DBIx::Error $err) {
      $self->app->log->error($err->message);
      return $self->reply->exception;
   }
}

1;
