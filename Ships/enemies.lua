
function spawn_ufo()
  local pex = math.random(-200, -100) + 2120 * math.random(0, 1)
  local pey = math.random(1080)
  local px = (ship.x + ship.width / 2) - pex
  local py = (ship.y + ship.height / 2) - pey
  local pdistance = math.sqrt(px * px + py * py)
  for a, b in ipairs(enemy) do
    if not enemy[a].is_active then
      enemy[a].x = pex
      enemy[a].y = pey
      enemy[a].color = {0.6, 0.6, 1} --{math.random(0, 1), 1, math.random(0, 1)}
      enemy[a].hp = 20
      enemy[a].sprite = asteroid
      enemy[a].height = 75
      enemy[a].width = 75
      enemy[a].x_speed = px/pdistance * 3
      enemy[a].y_speed = py/pdistance * 3
      enemy[a].score = 100
      enemy[a].inv_timer = 0
      enemy[a].rotation = 0
      enemy[a].rotation_speed = math.random()
      enemy[a].has_particle = false
      enemy[a].particle_timer = 99
      enemy[a].ability = 0
      enemy[a].ability_timer = 1000
      enemy[a].ability_cooldown = 1000
      enemy[a].death_ability = 0
      enemy[a].is_active = true
      break
    end
  end
end

function spawn_shooter()
  local pex = math.random(-200, -100) + 2120 * math.random(0, 1)
  local pey = math.random(1080)
  local px = (ship.x + ship.width / 2) - pex
  local py = (ship.y + ship.height / 2) - pey
  local pdistance = math.sqrt(px * px + py * py)
  for a, b in ipairs(enemy) do
    if not enemy[a].is_active then
      enemy[a].x = pex
      enemy[a].y = pey
      enemy[a].color = {0, 1, 0.2} --{math.random(0, 1), 1, math.random(0, 1)}
      enemy[a].hp = 20
      enemy[a].sprite = shooter
      enemy[a].height = 39
      enemy[a].width = 75
      enemy[a].x_speed = px/pdistance
      enemy[a].y_speed = 0
      enemy[a].score = 200
      enemy[a].inv_timer = 0
      enemy[a].rotation = math.atan2(0, pex - ship.x)
      enemy[a].rotation_speed = 0
      enemy[a].has_particle = true
      enemy[a].particle_timer = 0.1
      enemy[a].ability = {function(a) return enemy_shoot(a) end}
      enemy[a].ability_timer = 2
      enemy[a].ability_cooldown = 4
      enemy[a].death_ability = 0
      enemy[a].is_active = true
      break
    end
  end
end

function spawn_hunter()
  boss_on = boss_on + 1
  for a, b in ipairs(enemy) do
    if not enemy[a].is_active then  
      enemy[a].x = 2000
      enemy[a].y = 440
      enemy[a].color = {1, 0.2, 0} --{math.random(0, 1), 1, math.random(0, 1)}
      enemy[a].hp = 500
      enemy[a].sprite = hunter
      enemy[a].height = 63
      enemy[a].width = 63
      enemy[a].x_speed = -1
      enemy[a].y_speed = 0
      enemy[a].score = 10000
      enemy[a].inv_timer = 0
      enemy[a].rotation = math.pi
      enemy[a].rotation_speed = 0
      enemy[a].has_particle = true
      enemy[a].particle_timer = 0.1
      enemy[a].ability = {function(a) return enemy_home2(a) end, function(a) return enemy_teleport(a) end}
      enemy[a].ability_timer = 3
      enemy[a].ability_cooldown = 1.5
      enemy[a].death_ability = hunter_death
      enemy[a].is_active = true
      break
    end
  end
end

function spawn_hunter2()
  boss_on = boss_on + 1
  for a, b in ipairs(enemy) do
    if not enemy[a].is_active then 
      enemy[a].x = 2000
      enemy[a].y = 540
      enemy[a].color = {0, 0.8, 0} --{math.random(0, 1), 1, math.random(0, 1)}
      enemy[a].hp = 500
      enemy[a].sprite = hunter
      enemy[a].height = 63
      enemy[a].width = 63
      enemy[a].x_speed = -1
      enemy[a].y_speed = 0
      enemy[a].score = 8000
      enemy[a].inv_timer = 0
      enemy[a].rotation = math.pi
      enemy[a].rotation_speed = 0
      enemy[a].has_particle = true
      enemy[a].particle_timer = 0.1
      enemy[a].ability = {function(a) return enemy_home2(a) end}
      enemy[a].ability_timer = 3
      enemy[a].ability_cooldown = 0
      enemy[a].death_ability = hunter_death
      enemy[a].is_active = true
      break
    end
  end
end

function spawn_hunter3()
  boss_on = boss_on + 1
  for a, b in ipairs(enemy) do
    if not enemy[a].is_active then 
      enemy[a].x = 2000
      enemy[a].y = 640
      enemy[a].color = {0, 0, 0.8} --{math.random(0, 1), 1, math.random(0, 1)}
      enemy[a].hp = 500
      enemy[a].sprite = hunter
      enemy[a].height = 63
      enemy[a].width = 63
      enemy[a].x_speed = -1
      enemy[a].y_speed = 0
      enemy[a].score = 10000
      enemy[a].inv_timer = 0
      enemy[a].rotation = math.pi
      enemy[a].rotation_speed = 0
      enemy[a].has_particle = true
      enemy[a].particle_timer = 0.1
      enemy[a].ability = {function(a) return enemy_stop_shoot(a) end, function(a) return enemy_home(a) end}
      enemy[a].ability_timer = 3
      enemy[a].ability_cooldown = 1.5
      enemy[a].death_ability = hunter_death
      enemy[a].is_active = true
      break
    end
  end
end

function spawn_asteroid()
  local pex = math.random(1920)
  local pey = math.random(-200, -100) + 1480 * math.random(0, 1)
  local px = (ship.x + ship.width / 2) - pex
  local py = (ship.y + ship.height / 2) - pey
  local pdistance = math.sqrt(px * px + py * py)
  for a, b in ipairs(enemy) do
    if not enemy[a].is_active then 
      enemy[a].x = pex
      enemy[a].y = pey
      enemy[a].color = {1, 0.6, 0} --{math.random(0, 1), 1, math.random(0, 1)}
      enemy[a].hp = 20
      enemy[a].sprite = asteroid1
      enemy[a].height = 75
      enemy[a].width = 75
      enemy[a].x_speed = 0
      enemy[a].y_speed = py/pdistance * 2
      enemy[a].score = 100
      enemy[a].inv_timer = 0
      enemy[a].rotation = 0
      enemy[a].rotation_speed = math.random()
      enemy[a].has_particle = false
      enemy[a].particle_timer = 99
      enemy[a].ability = 0
      enemy[a].ability_timer = 1000
      enemy[a].ability_cooldown = 1000
      enemy[a].death_ability = function(a) return spawn_cluster(a) end
      enemy[a].is_active = true
      break
    end
  end
end

function spawn_cluster(c)
  for e = 1, 3 do
    for a, b in ipairs(enemy) do
      if not enemy[a].is_active then 
        enemy[a].x = enemy[c].x
        enemy[a].y = enemy[c].y
        enemy[a].color = {1, 0.6, 0} --{math.random(0, 1), 1, math.random(0, 1)}
        enemy[a].hp = 1
        enemy[a].sprite = asteroid2
        enemy[a].height = 25
        enemy[a].width = 25
        enemy[a].x_speed = math.random(-10, 10)/4
        enemy[a].y_speed = math.random(-10, 10)/4
        enemy[a].score = 30
        enemy[a].inv_timer = 0
        enemy[a].rotation = 0
        enemy[a].rotation_speed = math.random()
        enemy[a].has_particle = false
        enemy[a].particle_timer = 99
        enemy[a].ability = 0
        enemy[a].ability_timer = 1000
        enemy[a].ability_cooldown = 1000
        enemy[a].death_ability = 0
        enemy[a].is_active = true
        break
      end
    end
  end
end

function spawn_tnt()
  local pex = math.random(-200, -100) + 2120 * math.random(0, 1)
  local pey = math.random(1080)
  local px = (ship.x + ship.width / 2) - pex
  local py = (ship.y + ship.height / 2) - pey
  local pdistance = math.sqrt(px * px + py * py)
  for a, b in ipairs(enemy) do
    if not enemy[a].is_active then 
      enemy[a].x = pex
      enemy[a].y = pey
      enemy[a].color = {0.8, 0, 0}
      enemy[a].hp = 1
      enemy[a].sprite = tnt
      enemy[a].height = 75
      enemy[a].width = 75
      enemy[a].x_speed = px/pdistance
      enemy[a].y_speed = 0
      enemy[a].score = 100
      enemy[a].inv_timer = 0
      enemy[a].rotation = 0
      enemy[a].rotation_speed = math.random()
      enemy[a].has_particle = false
      enemy[a].particle_timer = 99
      enemy[a].ability = 0
      enemy[a].ability_timer = 1000
      enemy[a].ability_cooldown = 1000
      enemy[a].death_ability = function(a) return enemy_shoot_spread(a) end
      enemy[a].is_active = true
      break
    end
  end
end

function enemy_switch(a)
  local tx = 0
  local ty = 0
  local ttx = 0
  local tty = 0
  tx = enemy[a].x
  ty = enemy[a].y
  enemy[a].x = 8000
  enemy[a].y = 8000
  ttx = ship.x
  tty = ship.y
  ship.x = tx
  ship.y = ty
  enemy[a].x = ttx
  enemy[a].y = tty
  
  for e = 1, 20 do
    phc = math.random() + 0.5
    for c, b in ipairs(particle) do
      if particle[c].is_active == false then
        particle[c].x = enemy[a].x
        particle[c].y = enemy[a].y
        particle[c].color = {enemy[a].color[1]/phc, enemy[a].color[2]/phc, enemy[a].color[3]/phc}
        particle[c].x_speed = math.random(-10, 10)/5
        particle[c].y_speed = math.random(-10, 10)/5
        particle[c].gravity = 0
        particle[c].scale = 2
        particle[c].decay = 1
        particle[c].is_active = true
        break
      end
    end
  end
  table.insert(explosion.x, enemy[a].x)
  table.insert(explosion.y, enemy[a].y)
  table.insert(explosion.scale, 1)
  table.insert(explosion.limit, 30)
  table.insert(explosion.decay, 100)
  table.insert(explosion.color, enemy[a].color)
  
  for e = 1, 20 do
    phc = math.random() + 0.5
    for c, b in ipairs(particle) do
      if particle[c].is_active == false then
        particle[c].x = ship.x
        particle[c].y = ship.y
        particle[c].color = {0, 0, phc}
        particle[c].x_speed = math.random(-10, 10)/5
        particle[c].y_speed = math.random(-10, 10)/5
        particle[c].gravity = 0
        particle[c].scale = 2
        particle[c].decay = 1
        particle[c].is_active = true
        break
      end
    end
  end
  table.insert(explosion.x, ship.x)
  table.insert(explosion.y, ship.y)
  table.insert(explosion.scale, 1)
  table.insert(explosion.limit, 30)
  table.insert(explosion.decay, 100)
  table.insert(explosion.color, {0, 0, 1})
  
  enemy_home2(a)
end

function enemy_shoot(a)
  local px = (ship.x) - enemy[a].x
  local py = (ship.y) - enemy[a].y
  local pdistance = math.sqrt(px * px + py * py)
  
  table.insert(enemy_projectile.x, enemy[a].x)
  table.insert(enemy_projectile.y, enemy[a].y)
  table.insert(enemy_projectile.color, {1, 1, 0.5}) --{math.random(0, 1), 1, math.random(0, 1)}
  table.insert(enemy_projectile.sprite, bullet1)
  table.insert(enemy_projectile.rotation, math.atan2(ship.y - enemy[a].y, ship.x - enemy[a].x))
  table.insert(enemy_projectile.height, 9)
  table.insert(enemy_projectile.width, 9)
  table.insert(enemy_projectile.x_speed, px/pdistance * 3 * 2)
  table.insert(enemy_projectile.y_speed, py/pdistance * 3 * 2)
end

function enemy_stop_shoot(a)
  local px = (ship.x) - enemy[a].x
  local py = (ship.y) - enemy[a].y
  local pdistance = math.sqrt(px * px + py * py)
  for e = 1, 3 do
    table.insert(enemy_projectile.x, enemy[a].x)
    table.insert(enemy_projectile.y, enemy[a].y)
    table.insert(enemy_projectile.color, {1, 1, 0.5}) --{math.random(0, 1), 1, math.random(0, 1)}
    table.insert(enemy_projectile.sprite, bullet1)
    table.insert(enemy_projectile.rotation, math.atan2(ship.y - enemy[a].y, ship.x - enemy[a].x))
    table.insert(enemy_projectile.height, 9)
    table.insert(enemy_projectile.width, 9)
    table.insert(enemy_projectile.x_speed, px/pdistance * 14 + math.random(-10, 10)/7)
    table.insert(enemy_projectile.y_speed, py/pdistance * 14 + math.random(-10, 10)/7)
  end
  
  enemy[a].x_speed = px/pdistance
  enemy[a].y_speed = py/pdistance
  enemy[a].rotation = math.atan2(ship.y - enemy[a].y, ship.x - enemy[a].x)

end
function enemy_teleport(a)
  for e = 1, 20 do
    phc = math.random()
    for c, b in ipairs(particle) do
      if particle[c].is_active == false then
        particle[c].x = enemy[a].x
        particle[c].y = enemy[a].y
        particle[c].color = {phc, phc, phc}
        particle[c].x_speed = math.random(-10, 10)/5
        particle[c].y_speed = math.random(-10, 10)/5
        particle[c].gravity = 0
        particle[c].scale = 2
        particle[c].decay = 1
        particle[c].is_active = true
        break
      end
    end
  end
  
  local sx = enemy[a].x - ship.x
  local sy = enemy[a].y - ship.y
  enemy[a].x = enemy[a].x - 1.5 * sx
  enemy[a].y = enemy[a].y - 1.5 * sy
  
  for e = 1, 20 do
    phc = math.random()
    for c, b in ipairs(particle) do
      if particle[c].is_active == false then
        particle[c].x = enemy[a].x
        particle[c].y = enemy[a].y
        particle[c].color = {phc, phc, phc}
        particle[c].x_speed = math.random(-10, 10)/5
        particle[c].y_speed = math.random(-10, 10)/5
        particle[c].gravity = 0
        particle[c].scale = 2
        particle[c].decay = 1
        particle[c].is_active = true
        break
      end
    end
  end
  local px = (ship.x) - enemy[a].x
  local py = (ship.y) - enemy[a].y
  local pdistance = math.sqrt(px * px + py * py)
  enemy[a].x_speed = px/pdistance * 5
  enemy[a].y_speed = py/pdistance * 5
  enemy[a].rotation = math.atan2(ship.y - enemy[a].y, ship.x - enemy[a].x)
end

function enemy_home(a)
  local px = (ship.x) - enemy[a].x
  local py = (ship.y) - enemy[a].y
  local pdistance = math.sqrt(px * px + py * py)
  enemy[a].x_speed = px/pdistance * 2
  enemy[a].y_speed = py/pdistance * 2
  enemy[a].rotation = math.atan2(ship.y - enemy[a].y, ship.x - enemy[a].x)

  for e = 1, 6 do
    table.insert(enemy_projectile.x, enemy[a].x)
    table.insert(enemy_projectile.y, enemy[a].y)
    table.insert(enemy_projectile.color, {1, 1, 0.5}) --{math.random(0, 1), 1, math.random(0, 1)}
    table.insert(enemy_projectile.sprite, bullet1)
    table.insert(enemy_projectile.rotation, 0)
    table.insert(enemy_projectile.height, 9)
    table.insert(enemy_projectile.width, 9)
    table.insert(enemy_projectile.x_speed, enemy[a].x_speed * 2 + math.random(-10, 10)/5)
    table.insert(enemy_projectile.y_speed, enemy[a].y_speed * 2 + math.random(-10, 10)/5)
  end

  for e = 1, 10 do
    for c, b in ipairs(particle) do
      if particle[c].is_active == false then
        particle[c].x = enemy[a].x
        particle[c].y = enemy[a].y
        particle[c].color = {1, math.random(), 0}
        particle[c].x_speed = math.random(-10, 10)/5
        particle[c].y_speed = math.random(-10, 10)/5
        particle[c].gravity = 0
        particle[c].scale = 2
        particle[c].decay = 1
        particle[c].is_active = true
        break
      end
    end
  end
end

function enemy_home2(a)
  local px = (ship.x) - enemy[a].x
  local py = (ship.y) - enemy[a].y
  local pdistance = math.sqrt(px * px + py * py)
  enemy[a].x_speed = px/pdistance * 2.2
  enemy[a].y_speed = py/pdistance * 2.2
  enemy[a].rotation = math.atan2(ship.y - enemy[a].y, ship.x - enemy[a].x)
end

function enemy_shoot_spread(a)
  for e = 1, 3 do
    table.insert(explosion.x, enemy[a].x + math.random(-20, 20))
    table.insert(explosion.y, enemy[a].y + math.random(-20, 20))
    table.insert(explosion.scale, math.random()/2 + 1)
    table.insert(explosion.limit, 50 * math.random())
    table.insert(explosion.decay, 200)
    table.insert(explosion.color, {1, math.random(), 0})
  end
  
  for e = 1, math.floor(30 * particle_rate) do
    for c, b in ipairs(particle) do
      if particle[c].is_active == false then
        particle[c].x = enemy[a].x
        particle[c].y = enemy[a].y
        particle[c].color = {1, math.random(), 0}
        particle[c].x_speed = math.random(-10, 10)/3
        particle[c].y_speed = math.random(-10, 10)/3
        particle[c].gravity = 0
        particle[c].scale = 2
        particle[c].decay = 4
        particle[c].is_active = true
        break
      end
    end
  end
  
  for e = #enemy, 1, -1 do
    local px = enemy[a].x - enemy[e].x
    local py = enemy[a].y - enemy[e].y
    local pdistance = math.sqrt(px * px + py * py)
    if pdistance < 300 then
      enemy[e].hp = enemy[e].hp - 100
    end
  end
  
  table.insert(enemy_projectile.x, enemy[a].x)
  table.insert(enemy_projectile.y, enemy[a].y)
  table.insert(enemy_projectile.color, {1, 1, 0.5}) --{math.random(0, 1), 1, math.random(0, 1)}
  table.insert(enemy_projectile.sprite, bullet1)
  table.insert(enemy_projectile.rotation, 0)
  table.insert(enemy_projectile.height, 9)
  table.insert(enemy_projectile.width, 9)
  table.insert(enemy_projectile.x_speed, 0)
  table.insert(enemy_projectile.y_speed, 2)

  table.insert(enemy_projectile.x, enemy[a].x)
  table.insert(enemy_projectile.y, enemy[a].y)
  table.insert(enemy_projectile.color, {1, 1, 0.5}) --{math.random(0, 1), 1, math.random(0, 1)}
  table.insert(enemy_projectile.sprite, bullet1)
  table.insert(enemy_projectile.rotation, 0)
  table.insert(enemy_projectile.height, 9)
  table.insert(enemy_projectile.width, 9)
  table.insert(enemy_projectile.x_speed, -2)
  table.insert(enemy_projectile.y_speed, 0)
  
  table.insert(enemy_projectile.x, enemy[a].x)
  table.insert(enemy_projectile.y, enemy[a].y)
  table.insert(enemy_projectile.color, {1, 1, 0.5}) --{math.random(0, 1), 1, math.random(0, 1)}
  table.insert(enemy_projectile.sprite, bullet1)
  table.insert(enemy_projectile.rotation, 0)
  table.insert(enemy_projectile.height, 9)
  table.insert(enemy_projectile.width, 9)
  table.insert(enemy_projectile.x_speed, 2)
  table.insert(enemy_projectile.y_speed, 0)
  
  table.insert(enemy_projectile.x, enemy[a].x)
  table.insert(enemy_projectile.y, enemy[a].y)
  table.insert(enemy_projectile.color, {1, 1, 0.5}) --{math.random(0, 1), 1, math.random(0, 1)}
  table.insert(enemy_projectile.sprite, bullet1)
  table.insert(enemy_projectile.rotation, 0)
  table.insert(enemy_projectile.height, 9)
  table.insert(enemy_projectile.width, 9)
  table.insert(enemy_projectile.x_speed, 0)
  table.insert(enemy_projectile.y_speed, -2)
end

function hunter_death()
  boss_on = boss_on - 1
  if ship.hp < ship.max_hp then
    ship.hp = ship.hp + 1
  end
end