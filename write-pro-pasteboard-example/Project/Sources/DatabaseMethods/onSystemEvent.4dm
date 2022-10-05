C_LONGINT:C283($1; $vL_SystemEvent)

$vL_SystemEvent:=$1

If (Application type:C494#4D Server:K5:6)
	CALL WORKER:C1389(Current method name:C684; Formula:C1597(SystemEventDelegate).source; $vL_SystemEvent)
End if 