add_cus_dep('mtx', 'tex', 0, 'musixtex');
add_cus_dep('mtx', 'pdf', 0, 'musixtex');
add_cus_dep('mx1', 'mx2', 0, 'musixflx');

push @generated_exts, 'pmx', 'mx1', 'mx2';

sub musixtex {
  my $base = shift @_;
  unlink %R.mx1;
  unlink %R.mx2;
  unlink $base.pdf;
  unlink $base-crop.pdf;
  system("musixtex -t -F pdftex $base.mtx");
  return system("pdfcrop $base.pdf $base-crop.pdf");
}

sub musixflx {
  my $base = shift @_;
  unlink %R.mx2;
  return system("musixflx $base");
}