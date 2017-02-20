package Asr::Controller::Api::Users::Search;

use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';

use Mojolicious::Routes::Pattern;
use TryCatch;
use Asr::Controller::Utils qw/generate_hal_links validate_paging_params parse_sort_params/;

sub root {
   my $c = shift;
   my $result = Data::HAL->new();
   my $links = [{
      relation => 'self',
      templated => 0,
      href => '/api/users/search'
   },{
      relation => 'findBySite',
      templated => 1,
      href => '/api/users/search/findBySite',
      params => '{?size,index,sort,start,end,site}'
   }];

   $result->links(&generate_hal_links($c, $links));

   $c->render(text => $result->as_json, format => 'haljson');
}

sub find_by_site {
   my $self = shift;
   my ($site, $start, $end, $tag, $page_size, $page_index, $order, $rs);
   my $result = Data::HAL->new();
   my $links = [{
      relation => 'self',
      templated => 1,
      href => '/api/users/search/findBySite',
      params => '{?size,index,sort,start,end,site}'
   }];
   my $dtf = $self->schema->storage->datetime_parser;

   &validate_paging_params($self, qw/site bytes time bytes_percent time_percent/);

   #The failed validation method requires Mojolicious 6.0
   if ($self->validation->has_error) {
      $self->stash(
         message => "The following parameters failed validation: @{$self->validation->failed}"
      );
      return $self->render(template => 'client_error', status => 400)
   }

   $site       = $self->param('site');
   $start      = $self->param('start') // $dtf->format_datetime(DateTime->now->subtract(days => 15)),
   $end        = $self->param('end') // $dtf->format_datetime(DateTime->now),
   $tag        = $self->param('tag') // 'default';
   $page_size  = $self->validation->param('size') // $self->config->{page_size};
   $page_index = $self->validation->param('index') // $self->config->{page_index};
   $order      = &parse_sort_params($self);

   $rs = $self->schema->resultset('UserSiteHourly')->sum_by_user(
      $site, $start, $end, $tag, $page_size, $page_index, $order);

   $result->resource({
      page => {
         index => $rs->pager->current_page,
         size => $rs->pager->entries_per_page,
         totalItems => $rs->pager->total_entries + 0E0,
      }
   });

   $result->links(&generate_hal_links($self, $links));

   my @embedded = map {
      my $links = [];
      # my $links = [{
      #    relation => 'self',
      #    href => "/api/users/${\$_->id}",
      #    templated => 0,
      # }];
      Data::HAL->new(
      resource => {
         'remote_user' => $_->get_column('remote_user'),
         'bytes' => $_->get_column('bytes'),
         'bytes_percent' => $_->get_column('bytes_percent'),
         'time' => $_->get_column('time'),
         'time_percent' => $_->get_column('time_percent'),
      },
      relation => 'users',
      links => &generate_hal_links($self, $links)
      );
   } $rs->all;

   $result->embedded(\@embedded);

   $self->render(text => $result->as_json, format => 'haljson');
}

1;
