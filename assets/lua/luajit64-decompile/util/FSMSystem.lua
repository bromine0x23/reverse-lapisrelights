-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/FSMSystem.lua

Transition = {
	NullTransition = 0
}
StateID = {
	NullStateID = 0
}
FSMState = class("FSMState")
FSMState.map = nil
FSMState.stateID = nil

function FSMState:AddTransition(trans, id)
	if not self.map then
		self.map = {}
	end

	if trans == Transition.NullTransition then
		error("FSMState ERROR: NullTransition is not allowed for a real transition")

		return
	end

	if id == StateID.NullStateID then
		error("FSMState ERROR: NullStateID is not allowed for a real ID")

		return
	end

	if self.map[trans] ~= nil then
		error("FSMState ERROR: State " .. self.stateID .. " already has transition " .. trans .. " Impossible to assign to another state")

		return
	end

	self.map[trans] = id
end

function FSMState:DeleteTransition(trans)
	if trans == Transition.NullTransition then
		error("FSMState ERROR: NullTransition is not allowed")

		return
	end

	if self.map[trans] ~= nil then
		self.map[trans] = nil

		return
	end

	error("FSMState ERROR: Transition " .. trans .. " passed to " .. self.stateID .. " was not on the state's transition list")
end

function FSMState:GetOutputStateID(trans)
	if self.map[trans] ~= nil then
		return self.map[trans]
	end

	return StateID.NullStateID
end

function FSMState:DoBeforeEntering()
	return
end

function FSMState:DoBeforeLeaving()
	return
end

function FSMState:Reason(...)
	return
end

function FSMState:Act(...)
	return
end

FSMSystem = class("FSMSystem")
FSMSystem.states = nil
FSMSystem.currentStateID = nil
FSMSystem.currentState = nil

function FSMSystem:AddState(s)
	if not s then
		error("FSM ERROR: Null reference is not allowed")
	end

	if not self.states then
		self.states = {}

		table.insert(self.states, s)

		self.currentState = s
		self.currentStateID = s.stateID

		return
	end

	for i = 1, #self.states do
		if self.states[i].stateID == s.stateID then
			error("FSM ERROR: Impossible to add state " .. s.stateID .. " because state has already been added")

			return
		end
	end

	table.insert(self.states, s)
end

function FSMSystem:DeleteState(id)
	if id == StateID.NullStateID then
		error("FSM ERROR: NullStateID is not allowed for a real state")

		return
	end

	for i = 1, #self.states do
		if self.states[i].stateID == id then
			table.remove(self.states, i)

			return
		end
	end

	error("FSM ERROR: Impossible to delete state " .. id .. ". It was not on the list of states")
end

function FSMSystem:PerformTransition(trans)
	if trans == Transition.NullTransition then
		error("FSM ERROR: NullTransition is not allowed for a real transition")
	end

	local id = self.currentState:GetOutputStateID(trans)

	if id == StateID.NullStateID then
		print("-------***-------FSM Notice: State " .. self.currentStateID .. " does not have a target state " .. " for transition " .. trans)

		return
	end

	self.currentStateID = id

	for i = 1, #self.states do
		local state = self.states[i]

		if state.stateID == self.currentStateID then
			self.transition = trans

			self.currentState:DoBeforeLeaving()

			self.currentState = state

			self.currentState:DoBeforeEntering()

			return
		end
	end

	error("FSM Error: State " .. self.currentStateID .. " does not have a transition " .. trans)
end

function FSMSystem:Update()
	local currentState = self.currentState

	if currentState == nil then
		return
	end

	currentState:Act()
	currentState:Reason()
end

FSMStateTimer = class("FSMStateTimer", FSMState)

function FSMStateTimer:ctor(vTarget)
	self.Target = vTarget
end

function FSMStateTimer:DoBeforeEntering()
	self.WaitCounter = -1
end

function FSMStateTimer:IsOneShot()
	if self.WaitCounter == nil or self.WaitCounter == -1 then
		self.WaitCounter = 0

		return true
	else
		return false
	end
end

function FSMStateTimer:IncrTimer()
	self.WaitCounter = self.WaitCounter + Time.deltaTime

	return self.WaitCounter
end
