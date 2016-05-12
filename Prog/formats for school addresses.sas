
proc format; 
	value  $SCH_TYP 
			'1'='DCPS'
			'2'='PCSB'
			'3'='BOE'
			'5'='NCESCOMB';
	value   SWINGSCH
			0='No'
			1='Yes';
	value   combCHR
			0='No'
			1='Yes';

run; 