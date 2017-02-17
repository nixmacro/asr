package Asr::Schema::ResultSet::UserSiteHourly;

use Modern::Perl;
use base 'Asr::Schema::ResultSet';

sub sum_by_site {
   my ($self, $start, $end, $tag, $page_size, $page_index, @order) = @_;

   return sum_by(
      $self, 'site', $start, $end, $tag, $page_size, $page_index, @order);
}

sub sum_by_user {
   my ($self, $start, $end, $tag, $page_size, $page_index, @order) = @_;

   return sum_by(
      $self, 'remote_user', $start, $end, $tag, $page_size, $page_index, @order);
}

sub sum_by {
   my ($self, $col, $start, $end, $tag, $page_size, $page_index, @order) = @_;

   my ($tt_sql, @tt_args) = @{${$self->search({
      'local_time' => {
         -between => [
            $start,
            $end,
         ]
      }
   }, {
      columns => [
         {'total_time' => {sum => 'total_time', -as => 'total_time'}}
      ]
   })->as_query}};

   my ($tb_sql, @tb_args) = @{${$self->search({
      'local_time' => {
         -between => [
            $start,
            $end,
         ]
      }
   }, {
      columns => [
         {'total_bytes' => {sum => 'total_bytes', -as => 'total_bytes'}}
      ]
   })->as_query}};

   my $rs = $self->search({
         'local_time' => {
            -between => [
               $start,
               $end
            ]
         },
         'tag.name' => $tag
      }, {
         columns => [
            $col,
            {'bytes' => { sum => 'total_bytes', -as => 'bytes' }},
            {'seconds' => {sum => 'total_time', -as => 'seconds'}},
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
