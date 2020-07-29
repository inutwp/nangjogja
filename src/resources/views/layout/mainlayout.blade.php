<!doctype html>
<html lang="{{ app()->getLocale() }}">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <title>NangJogja</title>

  @include('partial.maincss')
  @yield('css')

</head>
<body>
	<div class="container-scroller">
		<div class="container py-4">
			<div class="main-wrapper">
				<div class="content-wrapper">
					@yield('content')
				</div>
				<footer class="footer-wrapper">
					@yield('footer')
				</footer>
			</div>
		</div>
	</div>

  @include('partial.mainjs')
  @yield('jsscript')
</body>
</html>
