package Asr::Controller::Api::Sites::Search;

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
      href => '/api/sites/search'
   },{
      relation => 'findByUser',
      templated => 1,
      href => '/api/sites/search/findByUser',
      params => '{?size,index,sort,start,end,user}'
   }];

   $result->links(&generate_hal_links($c, $links));

   $c->render(text => $result->as_json, format => 'haljson');
}

sub find_by_user {
   my $self = shift;
   my ($user, $start, $end, $tag, $page_size, $page_index, $order, $rs);
   my $result = Data::HAL->new();
   my $links = [{
      relation => 'self',
      templated => 1,
      href => '/api/sites/search/findByUser',
      params => '{?size,index,sort,start,end,user}'
   }];
   my $dtf = $self->schema->storage->datetime_parser;

   &validate_paging_params($self, qw/user bytes time bytes_percent time_percent/);

   #The failed validation method requires Mojolicious 6.0
   if ($self->validation->has_error) {
      $self->stash(
         message => "The following parameters failed validation: @{$self->validation->failed}"
      );
      return $self->render(template => 'client_error', status => 400)
   }

   $user       = $self->param('user');
   $start      = $self->param('start') // $dtf->format_datetime(DateTime->now->subtract(days => 15)),
   $end        = $self->param('end') // $dtf->format_datetime(DateTime->now),
   $tag        = $self->param('tag') // 'default';
   $page_size  = $self->validation->param('size') // $self->config->{page_size};
   $page_index = $self->validation->param('index') // $self->config->{page_index};
   $order      = &parse_sort_params($self);

   $rs = $self->schema->resultset('UserSiteHourly')->sum_by_site(
      $user, $start, $end, $tag, $page_size, $page_index, $order);

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
      #    href => "/api/sites/${\$_->id}",
      #    templated => 0,
      # }];
      Data::HAL->new(
      resource => {
         'site' => $_->get_column('site'),
         'bytes' => $_->get_column('bytes'),
         'bytes_percent' => $_->get_column('bytes_percent'),
         'time' => $_->get_column('time'),
         'time_percent' => $_->get_column('time_percent'),
      },
      relation => 'sites',
      links => &generate_hal_links($self, $links)
      );
   } $rs->all;

   $result->embedded(\@embedded);

   $self->render(text => $result->as_json, format => 'haljson');
}

1;
