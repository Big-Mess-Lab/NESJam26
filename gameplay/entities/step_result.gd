extends RefCounted
class_name StepResult

var outcome: GridEntity.Outcome
var strikes: Array = []
enum Part {BODY, ATTACHMENT}

func _init(p_outcome, p_strikes = []):
	outcome = p_outcome
	strikes = p_strikes
