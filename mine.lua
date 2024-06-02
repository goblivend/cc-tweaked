argv = {...}
argc = #argv

if argc < 2 then
  print("Usage: main <current_y> <target_y>")
  return
end

home_y = tonumber(argv[1])

fuel = "minecraft:coal"

ressource = "minecraft:coal_ore"
ressource_level = tonumber(argv[2]) --96

dx = 0
dy = 0
direction = 0

function go_to_level(level)
  while home_y + dy < level do
    if turtle.up() then
      dy = dy + 1
    else
      turtle.digUp()
    end
  end
  while home_y + dy > level do
    if turtle.down() then
      dy = dy - 1
    else
      turtle.digDown()
    end
  end
end

function back_home()
  while dx > 0 do
    if turtle.back() then
      dx = dx - 1
    else
      turtle.turnLeft()
      turtle.dig("left")
      turtle.turnRight()
    end
  end

  go_to_level(home_y)
end

function full_fuel()
  local data = turtle.getItemDetail(16)
  return data ~= nil and data.count == 64
end

function move_fuel()
  for i = 1, 15 do
    local data = turtle.getItemDetail(i)
    if data ~= nil and data.name == fuel then
      turtle.select(i)
      turtle.transferTo(16)
      if full_fuel() then
        break
      end
    end
  end
end

function refuel()
  if turtle.getFuelLevel() == "unlimited" then
    return
  end
  move_fuel()
  while turtle.getFuelLevel() < turtle.getFuelLimit() do
    turtle.select(16)
    local data = turtle.getItemDetail()
    local refueled, reason = turtle.refuel(data.count - 1)
    if not refueled then
      break
    end
    move_fuel()
    turtle.select(16)
    local data = turtle.getItemDetail()
    if data.count == 1 then
      break
    end
  end
end

function is_full()
  for i=1, 15 do
    turtle.select(i)
    local data = turtle.getItemDetail()
    if data == nil then
      return false
    end
  end
  return true
end

function low_fuel()
  refuel()
  return turtle.getFuelLevel() <= dx - dy + 50
end

function mine_vein_up()
  local has_block, data = turtle.inspectUp()
  if has_block and data.name == ressource then
    turtle.digUp()
    turtle.up()
    mine_vein()
    turtle.down()
  end
end

function mine_vein_down()
  local has_block, data = turtle.inspectDown()
  if has_block and data.name == ressource then
    turtle.digDown()
    turtle.down()
    mine_vein()
    turtle.up()
  end
end

function mine_vein_left()
  turtle.turnLeft()
  local has_block, data = turtle.inspect()
  if has_block and data.name == ressource then
    turtle.dig()
    turtle.forward()
    mine_vein()
    turtle.back()
  end
  turtle.turnRight()
end

function mine_vein_right()
  turtle.turnRight()
  local has_block, data = turtle.inspect()
  if has_block and data.name == ressource then
    turtle.dig()
    turtle.forward()
    mine_vein()
    turtle.back()
  end
  turtle.turnLeft()
end

function mine_vein_forward()
  local has_block, data = turtle.inspect()
  if has_block and data.name == ressource then
    turtle.dig()
    turtle.forward()
    mine_vein()
    turtle.back()
  end
end

function mine_vein_back()
  turtle.turnRight()
  turtle.turnRight()
  local has_block, data = turtle.inspect()
  if has_block and data.name == ressource then
    turtle.dig()
    turtle.forward()
    mine_vein()
    turtle.back()
  end
  turtle.turnLeft()
  turtle.turnLeft()
end

function mine_vein()
  if is_full() or low_fuel() then
    return
  end
  mine_vein_down()
  mine_vein_up()
  mine_vein_left()
  mine_vein_right()
  mine_vein_back()
  mine_vein_forward()
end

function mine_straight_vein()
  if is_full() or low_fuel() then
    return
  end
  mine_vein_down()
  mine_vein_up()
  mine_vein_left()
  mine_vein_right()
end

refuel()
if turtle.getFuelLevel() < 200 then
  print("Not enough fuel to start" .. turtle.getFuelLevel())
  return
end

go_to_level(ressource_level)
print("Arrived at ressource level")

while true do
  refuel()

  turtle.dig()
  if turtle.forward() then
    dx = dx + 1
  end

  mine_straight_vein()

  if is_full() then
    print("Full of stuff")
    break
  end

  if low_fuel() then
    print("Low on fuel")
    break
  end
end

print("Returning home with :" .. turtle.getFuelLevel() .. " fuel left")
back_home()

print("Back home")
