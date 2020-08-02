@extends('layout.mainlayout')

@section('content')
<div class="card">
	<div class="card-body">
		<div class="row mt-3">
			@foreach($data as $value)
				<div class="col-12 col-md-3 mb-3">
					<label><b>Name</b></label>
					<div class="input-group">
						<input type="text" class="form-control" readonly="true" value="{{$value['name']}}">
					</div>
				</div>

				<div class="col-12 col-md-3 mb-3">
					<label><b>ID</b></label>
					<div class="input-group">
						<input type="text" class="form-control" readonly="true" value="{{$value['id']}}">
					</div>
				</div>

				<div class="col-12 col-md-3 mb-3">
					<label><b>Phone</b></label>
					<div class="input-group">
						<input type="text" class="form-control" readonly="true" value="{{$value['telp']}}">
					</div>
				</div>

				<div class="col-12 col-md-3 mb-3">
					<label><b>Email</b></label>
					<div class="input-group">
						<input type="text" class="form-control" readonly="true" value="{{$value['email']}}">
					</div>
				</div>
      		@endforeach
		</div>
	</div>
</div>
@endsection

@section('jsscript')
@endsection
