<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Response;

class GenerateController extends Controller
{
	private $faker;

	public function __construct(){
		$this->faker = \Faker\Factory::create();
	}

	public function generate()
	{
		$createGenerate = rand(10,100);
		$createGenerate = (int) $createGenerate;
		$name = [];
		$id = [];
		$telp = [];
		$email = [];
		$data['from'] = substr($_SERVER['SERVER_ADDR'],7);
		$data['process'] = 0;

		$startProcess = microtime(true);

		for ($i=0; $i < $createGenerate; $i++) {
			$name[$i] = $this->generateName();
			if ($name[$i]) {
				$extract = explode(' ',$name[$i]);
				if ($extract[1] == 'Erza') {
					$name[$i] = $this->generateName();
				}
			}
			$id[$i] = abs(mt_rand((int)1111111111111111,(int)9999999911111111));
			$telp[$i] = '821'.mt_rand((int)11111111,(int)99999999);
			$email[$i] = $this->generateEmail();
			$datas = [
				'name' => $name[$i],
				'id' => $id[$i],
				'telp' => $telp[$i],
				'email' => $email[$i]
			];
			$data['generated'][] = $datas;
		}

		$endProcess = number_format(microtime(true) - $startProcess, 5);
		$data['process'] = $endProcess;

		$f = fopen(storage_path((string)__FUNCTION__.'.txt'), 'a+');
		$logs = json_encode([$data['from'],$data['process'], date('H:i')]);
        fwrite($f,$logs."\n");
        fclose($f);

		return response()->json($data);
	}

	public function generateName()
	{
		$name = $this->faker->name;
		$name = explode(' ',$name);
		$nameCount = count($name);
		if ($nameCount == 4) {
			$name = $name[1].' '.$name[2];
		} elseif ($nameCount == 3) {
			$name = $name[1].' '.'Erza';
		} else {
			$name = $name[0].' '.$name[1];
		}
		$name = str_replace("'",'',$name);
		$name = strtolower($name);
		$name = ucwords($name);
		return $name;
	}

	public function generateEmail()
	{
		$email = $this->faker->email;
		$email = explode('@',$email);
		$email = $email[0].'@'.'yomail.com';
		return $email;
	}
}
