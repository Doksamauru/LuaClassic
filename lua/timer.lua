timer = {
  active = {}
}

function timer.Simple(delay, func)
	return timer.Create('simpletimer' .. (os.time()*math.random()), 1, delay, func)
end

function timer.Create(id, reps, delay, func)
  if delay <= 0 then return timer end
  timer.active[id] = {
    repeats = reps,
		paused = false,
    delay = delay,
    curr = delay,
		func = func
  }
  return timer
end

function timer.Reset(id)
  local tmr = timer.active[id]
  if tmr then
    tmr.curr = tmr.delay
  end
end

function timer.IsCreated(id)
  return not not timer.active[id]
end

function timer.Remove(id)
	if timer.IsCreated(id)then
	  timer.active[id] = nil
	end
  return tuner
end

function timer.Pause(id)
	if timer.IsCreated(id)then
		timer.active[id].paused = true
	end
end

function timer.Resume(id)
	if timer.IsCreated(id)then
		timer.active[id].paused = false
	end
end

function timer.Update(dt)
  for id,data in pairs(timer.active)do
    if data.repeats ~= 0 then
			if not data.paused then
	      if data.curr > 0 then
	        data.curr = data.curr - dt
	      else
	        data.curr = data.delay
	        data.repeats = data.repeats - 1
					local status, ret = pcall(data.func, data.repeats)
					if not status then
						ret = tostring(ret)
						log.error((TMR_ERR):format(id, ret))
						timer.Pause(id)
					end
	      end
			end
    else
      timer.active[id] = nil
    end
  end
end
