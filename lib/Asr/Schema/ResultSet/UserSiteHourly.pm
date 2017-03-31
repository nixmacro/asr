package Asr::Schema::ResultSet::UserSiteHourly;

use Modern::Perl;
use base 'Asr::Schema::ResultSet';

sub sum_by_site {
   my ($self, $filter, $start, $end, $tag, $page_size, $page_index, @order) = @_;

   return sum_by(
      $self, 'site', 'remote_user', $filter, $start, $end, $tag, $page_size, $page_index, @order);
}

sub sum_by_user {
   my ($self, $filter, $start, $end, $tag, $page_size, $page_index, @order) = @_;

   return sum_by(
      $self, 'remote_user', 'site', $filter, $start, $end, $tag, $page_size, $page_index, @order);
}

sub sum_by {
   my ($self, $col, $filter_col, $filter_val, $start, $end, $tag, $page_size, $page_index, @order) = @_;
   my %where = (
      'local_time' => {
         -between => [
            $start,
            $end,
         ]
      },
   );

   $where{$filter_col} = $filter_val if defined($filter_val);
   $where{'tag.id'} = $tag if defined($tag);

   my ($tt_sql, @tt_args) = @{${$self->search(\%where, {
      columns => [
         {'total_time' => {sum => 'total_time', -as => 'total_time'}}
      ],
      join => 'tag'
   })->as_query}};

   my ($tb_sql, @tb_args) = @{${$self->search(\%where, {
      columns => [
         {'total_bytes' => {sum => 'total_bytes', -as => 'total_bytes'}}
      ],
      join => 'tag'
   })->as_query}};

   my $rs = $self->search(\%where, {
      columns => [
         $col,
         {'bytes' => { sum => 'total_bytes', -as => 'bytes' }},
         {'time' => {sum => 'total_time', -as => 'time'}},
         {'bytes_percent' => \["SUM(total_bytes) * 100 / $tb_sql AS bytes_percent", @tb_args]},
         {'time_percent' => \["SUM(total_time) * 100 / $tt_sql AS time_percent", @tt_args]},
      ],
      join => 'tag',
      rows => $page_size,
      page => $page_index,
      order_by => \@order,
      group_by => [
         $col
      ]
   });
}

1;
