require("enemies")
local shader_code = [[
extern number time;
extern float strength;

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
    // Simulate heat waves with sine + random-like distortion
    //float strength = 0.002; // Controls how strong the distortion is
    float offsetX = sin(texCoord.y * 100.0 + time * 5.0) * strength;
    float offsetY = cos(texCoord.x * 100.0 + time * 5.0) * strength * 0.5;

    // Slightly displace the coordinates
    vec2 distortedCoords = texCoord + vec2(offsetX, offsetY);
    vec4 pixel = Texel(texture, distortedCoords);

    return pixel * color;
}
]]

function initialize()
  speed = 0
  engine_active = 0
  cooldown = 0
  spawn_timer = 0
  spawn_timer_max = 1
  boss_on = 0
  boss_timer = 150
  boss_count = 3
  score = 0
  ph_counter = 0
  game_over_timer = 0
  combo = 1
  
  ship = {
    x = 200,
    y = 200,
    height = 45,
    width = 45,
    hp = 3,
    max_hp = 5,
    speed = 1,
    invincibility = 0,
    energy = 100,
    energy_regen = 3,
    current_ability = activate_ship_teleport,
    current_ability_cost = 25,
    ability_charges = {},
    ability_delay = {},
    ability_timer = {},
    ability = {activate_ship_teleport, activate_ship_barrage},
    weapon = {weapon1, weapon3}}
  
  current_abilities = {}
  
  bullet = {}
  for a = 1, 100 do
    bullet[a] = {
      x = 0, 
      y = 0, 
      color = 0, 
      x_speed = 0, 
      y_speed = 0, 
      height = 0, 
      width = 0, 
      rotation = 0, 
      sprite = 0, 
      damage = 0, 
      ability = 0, 
      ability_cooldown = 0, 
      ability_timer = 0, 
      lifetime = 0,
      impact_ability = 0,
      is_active = false}
  end
  particle = {}
  function init_particle(b)
    particle = {}
    for a = 1, b do
      particle[a] = {
        x = 0,
        y = 0,
        color = 0,
        x_speed = 0,
        y_speed = 0,
        gravity = 0,
        scale = 0,
        decay = 0,
        is_active = false}
    end
  end
  init_particle(particle_max)
  
  explosion = {
    x = {},
    y = {},
    scale = {},
    color = {},
    decay = {},
    limit = {}}
  
  enemy = {}
  for a = 1, 50 do
    enemy[a] = {
      x = 0,
      y = 0,
      color = 0,
      hp = 0,
      sprite = 0,
      height = 0,
      width = 0,
      x_speed = 0,
      y_speed = 0,
      score = 0,
      inv_timer = 0,
      rotation = 0,
      rotation_speed = 0,
      has_particle = 0,
      particle_timer = 0,
      ability = 0,
      ability_timer = 0,
      ability_cooldown = 0,
      death_ability = 0,
      is_active = false}
  end
  
  enemies = {spawn_ufo, spawn_shooter, spawn_tnt, spawn_asteroid, spawn_hunter, spawn_hunter2, spawn_hunter3}
  
  enemy_projectile = {
    x = {},
    y = {},
    color = {},
    sprite = {},
    height = {},
    width = {},
    rotation = {},
    x_speed = {},
    y_speed = {}}
end

function love.load(arg)
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  
  math.randomseed(os.time())
  width, height = love.window.getDesktopDimensions( )
  success = love.window.setMode(width, height, {fullscreen = true, usedpiscale = false, centered = true})
  love.mouse.setVisible(false)
  
  rg = love.graphics.newFont("rg.ttf", 25)
  rg2 = love.graphics.newFont("rg.ttf", 50)
  
  shad = love.graphics.newShader(shader_code)
  canvas = love.graphics.newCanvas(1920, 1080)

  bullet1 = love.graphics.newImage("images/bullet1.png")
  ship_image = love.graphics.newImage("images/ship1.png")
  particle1 = love.graphics.newImage("images/particle1.png")
  background = love.graphics.newImage("images/background.png")
  backgroundex = love.graphics.newImage("images/backgroundex.png")
  glow = love.graphics.newImage("images/glow.png")
  button_play = love.graphics.newImage("images/button_play.png")
  button_ship = love.graphics.newImage("images/button_ship.png")
  button_options = love.graphics.newImage("images/button_options.png")
  button_exit = love.graphics.newImage("images/button_exit.png")
  button_particles = love.graphics.newImage("images/button_particles.png")
  button_p100 = love.graphics.newImage("images/button_p100.png")
  button_m100 = love.graphics.newImage("images/button_m100.png")
  border_upgrade = love.graphics.newImage("images/border_upgrade.png")
  asteroid = love.graphics.newImage("images/asteroid.png")
  asteroid1 = love.graphics.newImage("images/asteroid1.png")
  asteroid2 = love.graphics.newImage("images/asteroid2.png")
  shooter = love.graphics.newImage("images/shooter.png")
  zeppelin = love.graphics.newImage("images/zeppelin.png")
  tnt = love.graphics.newImage("images/tnt.png")
  hunter = love.graphics.newImage("images/hunter.png")
  cursor = love.graphics.newImage("images/cursor2.png")
  line_stat = love.graphics.newImage("images/line_stat.png")
  
  laser = love.audio.newSource("music/laser.wav", "static")
  
  stage = 1
  
  ph_particle_max = 1000
  particle_max = 1000
  particle_rate = particle_max/1000
  game_over = false

  initialize()
  
  --bullet = {
  --  x = {},
  --  y = {},
  --  color = {},
  --  x_speed = {},
  --  y_speed = {},
  --  height = {},
  --  width = {},
  --  rotation = {},
  --  sprite = {},
  --  damage = {},
  --  ability = {},
  --  ability_cooldown = {},
  --  ability_timer = {},
  --  lifetime = {},
  --  impact_ability = {}}
  
  
end



function between(a, b, c)
  return (a >= b) and (a < c)
end

function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end

function love.update(dt)
  
  --t = t + dt
  --myShader:send("time", t)
  --shad:send("time", love.timer.getTime())
  --shad:send("strength", (combo - 1)/10000)
  
  fpscount = love.timer.getFPS( )
  mx = love.mouse.getX( ) * 1920/width
  my = love.mouse.getY( ) * 1080/height
  lclick = love.mouse.isDown(1)
  rclick = love.mouse.isDown(2)
  
  if stage == 1 then
    
  elseif stage == 2 then
    dy = my - ship.y
    dx = mx - ship.x
    distance = math.sqrt(dx * dx + dy * dy)
    
    if combo > 1 + dt * 2 then
      combo = combo - dt * boss_count * 1.5
    end
    
    if boss_on == 0 then
      boss_timer = boss_timer - dt
      if spawn_timer > 0 then
        spawn_timer = spawn_timer - dt
      else
        for a = 1, boss_count do
          enemies[math.random(4)]()
        end
        spawn_timer = spawn_timer_max
      end
      if boss_timer <= 0 then
        for a = 1, boss_count do
          enemies[4 + math.random(3)]()
        end
        boss_count = boss_count + 1
        boss_timer = 150
      end
    end

    if engine_active > 0.02 and not (between(mx, ship.x - ship.width, ship.x + ship.width) and between(my, ship.y - ship.height, ship.y + ship.height)) and not game_over then
      for a, b in ipairs(particle) do
        if particle[a].is_active == false then
          particle[a].x = ship.x
          particle[a].y = ship.y
          particle[a].color = {1, math.random(), 0}
          particle[a].x_speed = -(speed * (dx/distance) * (1 + combo/100) + math.random(-10, 10)/10)
          particle[a].y_speed = -(speed * (dy/distance) * (1 + combo/100) + math.random(-10, 10)/10)
          particle[a].gravity = 0
          particle[a].scale = speed/3 + 0.5 + combo/200
          particle[a].decay = 5
          particle[a].is_active = true
          break
        end
      end
      engine_active = 0
    else
      engine_active = engine_active + dt * particle_rate
    end
    if speed < 5 then
      speed = speed + dt * 3
    end

    if not game_over then
      if between(mx, ship.x - ship.width, ship.x + ship.width) and between(my, ship.y - ship.height, ship.y + ship.height) then
        ship.x = ship.x + speed * (dx/80) * dt * 144
        ship.y = ship.y + speed * (dy/80) * dt * 144
      else
        ship.x = ship.x + speed * (dx/distance) * dt * 144 * ship.speed
        ship.y = ship.y + speed * (dy/distance) * dt * 144 * ship.speed
      end
    else
      if game_over_timer < 2 then
        game_over_timer = game_over_timer + dt
      else
        game_over_timer = 0
      end
    end
    
    if ship.invincibility > 0 then
      ship.invincibility = ship.invincibility - dt
    end
    
    for a, b in pairs(current_abilities) do
      if ship.ability_charges[a] > 0 then
        if ship.ability_timer[a] <= 0 then
          ship.ability_timer[a] = ship.ability_delay[a]
          current_abilities[a]()
          ship.ability_charges[a] = ship.ability_charges[a] - 1
        else
          ship.ability_timer[a] = ship.ability_timer[a] - dt
        end
      else
        table.remove(ship.ability_charges, a)
        table.remove(ship.ability_delay, a)
        table.remove(ship.ability_timer, a)
        table.remove(current_abilities, a)
      end
    end
    
    if lclick and cooldown <= 0 and not game_over then
      ship.weapon[1]()
    else
      cooldown = cooldown - dt * (1 + combo/300)
    end
    
    --if rclick and type(ship.current_ability) == "function" then
    --  ship.current_ability()
    --end
    
    if ship.energy < 100 then
      ship.energy = ship.energy + dt * ship.energy_regen
    end
    
    for a = #enemy, 1, -1 do  -----------------------------------------------------------------------------------ENEMY FOR LOOP
      if enemy[a].is_active == true then
        enemy[a].x = enemy[a].x + enemy[a].x_speed * 144 * dt
        enemy[a].y = enemy[a].y + enemy[a].y_speed * 144 * dt
        enemy[a].rotation = enemy[a].rotation + enemy[a].rotation_speed * dt
        if enemy[a].inv_timer > 0 then
          enemy[a].inv_timer = enemy[a].inv_timer - dt * 5
        end
        
        if enemy[a].has_particle then
          if enemy[a].particle_timer <= 0 then
            for c, b in ipairs(particle) do
              if particle[c].is_active == false then
                particle[c].x = enemy[a].x
                particle[c].y = enemy[a].y
                particle[c].color = {1, math.random(), 0}
                particle[c].x_speed = -enemy[a].x_speed * 2 + math.random(-10, 10)/20
                particle[c].y_speed = -enemy[a].y_speed * 2 + math.random(-10, 10)/20
                particle[c].gravity = 0
                particle[c].scale = 2
                particle[c].decay = 4
                particle[c].is_active = true
                break
              end
            end
            enemy[a].particle_timer = 0.05
          else
            enemy[a].particle_timer = enemy[a].particle_timer - dt * particle_rate
          end
        end
        
        if enemy[a].ability_timer < 0 then
          if type(enemy[a].ability[1]) == "function" then
            local ph = math.random(1, #enemy[a].ability)
            enemy[a].ability[ph](a)
          end
          enemy[a].ability_timer = enemy[a].ability_cooldown
        else
          enemy[a].ability_timer = enemy[a].ability_timer - dt
        end
        if CheckCollision(enemy[a].x - enemy[a].width/2 + 5, enemy[a].y - enemy[a].height/2 + 5, enemy[a].width - 10, enemy[a].height - 10, ship.x - ship.width/2, ship.y - ship.height/2, ship.width, ship.height) and ship.invincibility <= 0 and not game_over then
          ship.hp = ship.hp - 1
          combo = 1
          ship.invincibility = 3
          for e = 1, math.floor(50 * particle_rate) do
            for c, b in ipairs(particle) do
              if particle[c].is_active == false then
                particle[c].x = ship.x
                particle[c].y = ship.y
                particle[c].color = {1, math.random(), 0}
                particle[c].x_speed = math.random(-10, 10)
                particle[c].y_speed = math.random(-10, 10)
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
          table.insert(explosion.limit, 100)
          table.insert(explosion.decay, 200)
          table.insert(explosion.color, {1, 0.5, 0})
          if ship.hp < 1 then
            game_over = true
          end
        end
        if (enemy[a].x > 3300 or enemy[a].x < -1300 or enemy[a].y > 2400 or enemy[a].y < -1300) and enemy[a].death_ability ~= hunter_death then--not(between(enemy[a].x, -700, 2600) or between(enemy[a].y, -500, 1600)) then
          if type(enemy[a].death_ability) == "function" then
            enemy[a].death_ability(a)
          end
          enemy[a].is_active = false
        elseif enemy[a].hp <= 0 then
          if type(enemy[a].death_ability) == "function" then
            enemy[a].death_ability(a)
          end
          for e = 1, math.floor(20 * particle_rate) do
            for c, b in ipairs(particle) do
              if particle[c].is_active == false then
                particle[c].x = enemy[a].x
                particle[c].y = enemy[a].y
                particle[c].color = enemy[a].color
                particle[c].x_speed = math.random(-10, 10)/3
                particle[c].y_speed = math.random(-10, 10)/3
                particle[c].gravity = 0
                particle[c].scale = 2
                particle[c].decay = 3
                particle[c].is_active = true
                break
              end
            end
          end
          if not game_over then
            score = score + enemy[a].score
          end
          combo = combo + 1
          enemy[a].is_active = false
          if spawn_timer_max > 0.6 then
            spawn_timer_max = spawn_timer_max - 0.003
          end
        end
      end
    end
    
    for ph = 1, 2 do
      for a = #bullet, 1, -1 do  -----------------------------------------------------------------------------------BULLET FOR LOOP
        if bullet[a].is_active then
          if bullet[a].lifetime > 0 then
            bullet[a].x = bullet[a].x + bullet[a].x_speed * dt * 144/2
            bullet[a].y = bullet[a].y + bullet[a].y_speed * dt * 144/2
            if bullet[a].ability_timer <= 0 then
              bullet[a].ability(a)
              bullet[a].ability_timer = bullet[a].ability_cooldown
            else
              bullet[a].ability_timer = bullet[a].ability_timer - dt/2
            end
            bullet[a].lifetime = bullet[a].lifetime - dt/2
          else
            if type(bullet[a].impact_ability) == "function" then
              bullet[a].impact_ability(a)
            end
            bullet[a].is_active = false
          end
        end
      end
      
      for b = #enemy, 1, -1 do 
        if enemy[b].is_active then
          for a = #bullet, 1, -1 do
            if bullet[a].is_active then
              local en_dx = enemy[b].x - bullet[a].x
              local en_dy = enemy[b].y - bullet[a].y
              local dist_sq = en_dx * en_dx + en_dy * en_dy
              if dist_sq < 100 * 100 then
                if CheckCollision(bullet[a].x - bullet[a].width/2, bullet[a].y - bullet[a].height/2, bullet[a].width, bullet[a].height, enemy[b].x - enemy[b].width/2, enemy[b].y - enemy[b].height/2, enemy[b].width, enemy[b].height) then
                  if type(bullet[a].impact_ability) == "function" then
                    bullet[a].impact_ability(a)
                  end
                  enemy[b].hp = enemy[b].hp - bullet[a].damage
                  enemy[b].inv_timer = 1
                  for e = 1, math.floor(5 * particle_rate) do
                    for c, d in ipairs(particle) do
                      if particle[c].is_active == false then
                        particle[c].x = enemy[b].x
                        particle[c].y = enemy[b].y
                        particle[c].color = enemy[b].color
                        particle[c].x_speed = math.random(-10, 10)
                        particle[c].y_speed = math.random(-10, 10)
                        particle[c].gravity = 0
                        particle[c].scale = 2
                        particle[c].decay = 12
                        particle[c].is_active = true
                        break
                      end
                    end
                  end
                  
                  table.insert(explosion.x, enemy[b].x)
                  table.insert(explosion.y, enemy[b].y)
                  table.insert(explosion.scale, 1)
                  table.insert(explosion.limit, 20)
                  table.insert(explosion.decay, 200)
                  table.insert(explosion.color, enemy[b].color)
                  
                  bullet[a].is_active = false
                end
              end
            end
          end
        end
      end
    end
    
    for a, b in ipairs(particle) do  -----------------------------------------------------------------------------PARTICLE FOR LOOP
      if particle[a].is_active == true then
        if particle[a].scale > 0 then
          particle[a].y_speed = particle[a].y_speed + particle[a].gravity * dt
          particle[a].x = particle[a].x + particle[a].x_speed * 144 * dt
          particle[a].y = particle[a].y + particle[a].y_speed * 144 * dt
          particle[a].scale = particle[a].scale - dt * particle[a].decay
        else
          particle[a].is_active = false
        end
      end
    end
    
    for a = #explosion.x, 1, -1 do  --------------------------------------------------------------------------------EXPLOSION FOR LOOP 
      if explosion.scale[a] < explosion.limit[a] then
        explosion.scale[a] = explosion.scale[a] + explosion.decay[a] * dt
      else
        table.remove(explosion.x, a)
        table.remove(explosion.y, a)
        table.remove(explosion.scale, a)
        table.remove(explosion.color, a)
        table.remove(explosion.decay, a)
        table.remove(explosion.limit, a)
      end
    end
    
    for a = #enemy_projectile.x, 1, -1 do  -------------------------------------------------------------------------ENEMY PROJECTILE FOR LOOP
      enemy_projectile.x[a] = enemy_projectile.x[a] + enemy_projectile.x_speed[a] * 144 * dt
      enemy_projectile.y[a] = enemy_projectile.y[a] + enemy_projectile.y_speed[a] * 144 * dt
      if CheckCollision(enemy_projectile.x[a] - enemy_projectile.width[a]/2, enemy_projectile.y[a] - enemy_projectile.height[a]/2, enemy_projectile.width[a], enemy_projectile.height[a], ship.x - ship.width/2 + 5, ship.y - ship.height/2 + 5, ship.width - 10, ship.height - 10) and ship.invincibility <= 0 and not game_over then
        ship.hp = ship.hp - 1
        combo = 1
        ship.invincibility = 3
        for e = 1, math.floor(50 * particle_rate) do
          for a, b in ipairs(particle) do
            if particle[a].is_active == false then
              particle[a].x = ship.x
              particle[a].y = ship.y
              particle[a].color = {1, math.random(), 0}
              particle[a].x_speed = math.random(-10, 10)
              particle[a].y_speed = math.random(-10, 10)
              particle[a].gravity = 0
              particle[a].scale = 2
              particle[a].decay = 1
              particle[a].is_active = true
              break
            end
          end
        end
        if ship.hp < 1 then
          game_over = true
        end
      
        table.insert(explosion.x, ship.x)
        table.insert(explosion.y, ship.y)
        table.insert(explosion.scale, 1)
        table.insert(explosion.limit, 100)
        table.insert(explosion.decay, 200)
        table.insert(explosion.color, {1, 0.5, 0})
        
        table.remove(enemy_projectile.x, a)
        table.remove(enemy_projectile.y, a)
        table.remove(enemy_projectile.color, a)
        table.remove(enemy_projectile.sprite, a)
        table.remove(enemy_projectile.rotation, a)
        table.remove(enemy_projectile.width, a)
        table.remove(enemy_projectile.height, a)
        table.remove(enemy_projectile.x_speed, a)
        table.remove(enemy_projectile.y_speed, a)
        break
      elseif enemy_projectile.x[a] < -200 or enemy_projectile.x[a] > 2100 or enemy_projectile.y[a] < -200 or enemy_projectile.y[a] > 1300 then
        table.remove(enemy_projectile.x, a)
        table.remove(enemy_projectile.y, a)
        table.remove(enemy_projectile.color, a)
        table.remove(enemy_projectile.sprite, a)
        table.remove(enemy_projectile.rotation, a)
        table.remove(enemy_projectile.width, a)
        table.remove(enemy_projectile.height, a)
        table.remove(enemy_projectile.x_speed, a)
        table.remove(enemy_projectile.y_speed, a)
        break
      end
    end
  end
end

function love.draw()

  --love.graphics.setShader(shad)
  love.graphics.setCanvas(canvas)
  love.graphics.clear()

  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.draw(backgroundex, -(ship.x / 10), -(ship.y / 10))
  
  for a, b in ipairs(particle) do
    if particle[a].is_active == true then
      love.graphics.setColor(particle[a].color)
      love.graphics.draw(glow, particle[a].x, particle[a].y, 0, particle[a].scale, particle[a].scale, 15, 15)
      love.graphics.draw(particle1, particle[a].x, particle[a].y, 0, particle[a].scale, particle[a].scale, 2, 2)
    end
  end
  
  for a, b in ipairs(explosion.x) do
    love.graphics.setColor(explosion.color[a][1], explosion.color[a][2], explosion.color[a][3], 1 - explosion.scale[a]/explosion.limit[a])
    love.graphics.draw(glow, explosion.x[a], explosion.y[a], 0, explosion.scale[a], explosion.scale[a], 15, 15)
  end

  for a = #bullet, 1, -1 do
    if bullet[a].is_active then
      love.graphics.setColor(bullet[a].color)
      love.graphics.draw(glow, bullet[a].x, bullet[a].y, 0, 1, 1, 15, 15)
      love.graphics.draw(bullet[a].sprite, bullet[a].x, bullet[a].y, bullet[a].rotation, 1, 1, 4, 4)
    end
  end
  
  for a = #enemy_projectile.x, 1, -1 do
    love.graphics.setColor(enemy_projectile.color[a])
    love.graphics.draw(glow, enemy_projectile.x[a], enemy_projectile.y[a], 0, 1, 1, 10, 10)
    love.graphics.draw(enemy_projectile.sprite[a], enemy_projectile.x[a] + enemy_projectile.width[a]/2, enemy_projectile.y[a] + enemy_projectile.height[a]/2, enemy_projectile.rotation[a], 1, 1, enemy_projectile.width[a]/2, enemy_projectile.height[a]/2)
  end
  
  for a, b in ipairs(enemy) do
    if enemy[a].is_active then
      love.graphics.setColor(enemy[a].color[1] + enemy[a].inv_timer, enemy[a].color[2] + enemy[a].inv_timer, enemy[a].color[3] + enemy[a].inv_timer)
      love.graphics.draw(glow, enemy[a].x, enemy[a].y, enemy[a].rotation, enemy[a].width/15, enemy[a].height/15, 15, 15)
      love.graphics.draw(enemy[a].sprite, enemy[a].x, enemy[a].y, enemy[a].rotation, 1, 1, enemy[a].width/2, enemy[a].height/2)
    end
  end
  
  if not game_over then
    love.graphics.setColor(0.2, 0.4, 1, (3-ship.invincibility)/3)
    love.graphics.draw(glow, ship.x, ship.y, 0, 3, 3, 15, 15)
    love.graphics.draw(ship_image, ship.x, ship.y, math.atan2(my - ship.y, mx - ship.x), 1, 1, ship.height/2, ship.width/2)
    love.graphics.setColor(-(ship.hp - 5)/2, (ship.hp-1)/2, 0)
    love.graphics.draw(line_stat, ship.x + ship.width/2 * 1.2, ship.y - ship.width * 1.2)
    love.graphics.printf(ship.hp .. "HP", rg, ship.x + ship.width * 1.2, ship.y - ship.width * 1.2, 1000, "left")  
  else
    if game_over_timer < 1 then
      love.graphics.setColor(1, 0, 0)
      love.graphics.printf("Game Over Man..\nTotal score: " .. score, rg2, 0, 500, 1920, "center")
    end
  end
  
  if stage == 1 then
    if between(mx, (1920 - 150)/2, (1920 + 150)/2) and between(my, (1080 - 90)/2, (1080 + 90)/2) then
      love.graphics.setColor(0.7, 1, 0.7)
      love.graphics.draw(button_play, 1920/2, 1080/2, 0, 1.1, 1.1, 75, 45)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(button_play, 1920/2, 1080/2, 0, 1, 1, 75, 45)
    end
    if between(mx, (1920 - 150)/2, (1920 + 150)/2) and between(my, (1080 - 90)/2 + 100, (1080 + 90)/2 + 100) then
      love.graphics.setColor(0.7, 1, 0.7)
      love.graphics.draw(button_ship, 1920/2, 1080/2 + 100, 0, 1.1, 1.1, 75, 45)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(button_ship, 1920/2, 1080/2 + 100, 0, 1, 1, 75, 45)
    end
    if between(mx, (1920 - 150)/2 - 45, (1920 + 150)/2 + 45) and between(my, (1080 - 90)/2 + 200, (1080 + 90)/2 + 200) then
      love.graphics.setColor(0.7, 1, 0.7)
      love.graphics.draw(button_options, 1920/2 - 45, 1080/2 + 200, 0, 1.1, 1.1, 75, 45)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(button_options, 1920/2 - 45, 1080/2 + 200, 0, 1, 1, 75, 45)
    end
    if between(mx, (1920 - 150)/2, (1920 + 150)/2) and between(my, (1080 - 90)/2 + 300, (1080 + 90)/2 + 300) then
      love.graphics.setColor(0.7, 1, 0.7)
      love.graphics.draw(button_exit, 1920/2, 1080/2 + 300, 0, 1.1, 1.1, 75, 45)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(button_exit, 1920/2, 1080/2 + 300, 0, 1, 1, 75, 45)
    end
  elseif stage == 2 then
    love.graphics.setColor(1, (100 - ship.energy)/100, 1)
    love.graphics.printf(math.floor(ship.energy), rg, mx + 25, my - 25, 1000, "left")
  elseif stage == 3 then

  elseif stage == 4 then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(button_particles, 100, 100)
    love.graphics.printf(ph_particle_max, rg2, 410, 110, 1000, "left")
    if between(mx, 100, 220) and between(my, 200, 290) then
      love.graphics.setColor(0.7, 1, 0.7)
      love.graphics.draw(button_m100, 160, 233, 0, 1.1, 1.1, 60, 33)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(button_m100, 160, 233, 0, 1, 1, 60, 33)
    end
    if between(mx, 280, 400) and between(my, 200, 290) then
      love.graphics.setColor(0.7, 1, 0.7)
      love.graphics.draw(button_p100, 340, 233, 0, 1.1, 1.1, 60, 33)
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(button_p100, 340, 233, 0, 1, 1, 60, 33)
    end
  end
  
  love.graphics.setColor(0.4, 0.4, 1)
  love.graphics.printf(score, rg2, 1600, 20, 1000, "left")
  
  love.graphics.print("Bullets: " .. #bullet, 100, 100)
  love.graphics.print("Enemies: " .. #enemy, 100, 120)
  love.graphics.print("Particles: " .. #particle, 100, 140)
  love.graphics.print("Enemy projectiles: " .. #enemy_projectile.x, 100, 160)
  love.graphics.print("Explosions: " .. #explosion.x, 100, 180)
  love.graphics.print("Active abilities: " .. #current_abilities, 100, 200)
  love.graphics.print("Screen Width: " .. width, 100, 220)
  love.graphics.print("Screen Height: " .. height, 100, 240)
  love.graphics.print("MX: " .. mx, 100, 260)
  love.graphics.print("MY: " .. my, 100, 280)
  love.graphics.print(boss_on, 100, 300)
  love.graphics.print(ph_counter, 100, 340)
  love.graphics.print("Combo: " .. combo, 100, 360)
  
  love.graphics.print("Boss timer: " .. boss_timer, 100, 320)
  if between(mx, ship.x - ship.width, ship.x + ship.width) and between(my, ship.y - ship.height, ship.y + ship.height) then
    love.graphics.print("TRUE", 100, 380)
  else
    love.graphics.print("FALSE", 100, 380)
  end
  
  for a, b in ipairs(ship.ability_charges) do
    love.graphics.print("Ability "..a.." charges: " .. ship.ability_charges[a], 100, 480 + a * 20)
  end
  
  love.graphics.setColor(1, 1, 0)
  love.graphics.draw(cursor, mx, my, 0, 1, 1, 27/2, 27/2)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
  
  --love.graphics.setShader(shad)
  love.graphics.draw(canvas, 0, 0, 0, width/1920, height/1080)
  --love.graphics.setShader()
end 

function love.mousepressed()
  if stage == 1 then
    if between(mx, (1920 - 150)/2, (1920 + 150)/2) and between(my, (1080 - 90)/2, (1080 + 90)/2) then
      stage = 2
      if game_over then
        game_over = false
        initialize()
      end
    elseif between(mx, (1920 - 150)/2, (1920 + 150)/2) and between(my, (1080 - 90)/2 + 100, (1080 + 90)/2 + 100) then
      stage = 3
    elseif between(mx, (1920 - 150)/2 - 45, (1920 + 150)/2 + 45) and between(my, (1080 - 90)/2 + 200, (1080 + 90)/2 + 200) then
      stage = 4
    elseif between(mx, (1920 - 150)/2, (1920 + 150)/2) and between(my, (1080 - 90)/2 + 300, (1080 + 90)/2 + 300) then
      love.event.quit()
    end 
  elseif stage == 2 then
    if love.mouse.isDown(2) and type(ship.current_ability) == "function" and not game_over then
      ship.current_ability()
    end
  elseif stage == 4 then
    if between(mx, 100, 220) and between(my, 200, 290) and ph_particle_max > 0 then
      ph_particle_max = ph_particle_max - 100 
    elseif between(mx, 280, 400) and between(my, 200, 290) then
      ph_particle_max = ph_particle_max + 100
    end
  end
end

function love.keypressed()
  if love.keyboard.isDown("escape") then
    if stage == 1 then
      stage = 2
    elseif stage >= 2 then
      if stage == 4 then
        if ph_particle_max ~= particle_max then
          particle_max = ph_particle_max
          init_particle(particle_max)
          particle_rate = particle_max/1000
        end
      end
      stage = 1
    end
  end
  if stage == 2 then
    if love.keyboard.isDown("1") then
      spawn_ufo()
    end
    if love.keyboard.isDown("2") then
      spawn_hunter()
    end
    if love.keyboard.isDown("3") then
      spawn_shooter()
    end
    if love.keyboard.isDown("4") then
      spawn_hunter3()
    end
    if love.keyboard.isDown("5") then
      spawn_tnt()
    end
    if love.keyboard.isDown("6") then
      spawn_hunter2()
    end
    if love.keyboard.isDown("q") and type(ship.ability[1]) == "function" then
      ship.ability[1]()
    end
    if love.keyboard.isDown("w") and type(ship.ability[2]) == "function" then
      ship.ability[2]()
    end
    if love.keyboard.isDown("e") and type(ship.ability[3]) == "function" then
      ship.ability[3]()
    end
  end
end

function bullet_particle(a)
  for c, b in ipairs(particle) do
    if particle[c].is_active == false then
      particle[c].x = bullet[a].x
      particle[c].y = bullet[a].y
      particle[c].color = bullet[a].color
      particle[c].x_speed = math.random(-10, 10)/30
      particle[c].y_speed = math.random(-10, 10)/30
      particle[c].gravity = 0
      particle[c].scale = 0.5
      particle[c].decay = 3
      particle[c].is_active = true
      break
    end
  end
end

function weapon1()
  --local angles = {0, math.rad(15), -math.rad(15)}
  local angles = {0, math.rad(8), -math.rad(8), math.rad(16), -math.rad(16)}
  for e = 1, #angles do
    local rotated_dx = dx * math.cos(angles[e]) - dy * math.sin(angles[e])
    local rotated_dy = dx * math.sin(angles[e]) + dy * math.cos(angles[e])
    
    for a, b in ipairs(bullet) do
      if not bullet[a].is_active then
        bullet[a].x = ship.x
        bullet[a].y = ship.y
        bullet[a].x_speed = 15 * (rotated_dx/distance)
        bullet[a].y_speed = 15 * (rotated_dy/distance)
        bullet[a].color = {1, math.random(0, 0.2) + 0.8, 0}
        bullet[a].height = 15
        bullet[a].width = 15
        bullet[a].sprite = bullet1
        bullet[a].rotation = math.atan2(my - ship.y, mx - ship.x)
        bullet[a].damage = 10
        bullet[a].ability = bullet_particle
        bullet[a].ability_timer = math.random(10, 20)/1300
        bullet[a].ability_cooldown = math.random(10, 20)/1300
        bullet[a].lifetime = 0.5
        bullet[a].impact_ability = 0
        bullet[a].is_active = true
        break
      end
    end
  end
  love.audio.stop(laser)
  love.audio.play(laser)
  cooldown = 0.1
end

function weapon2()
  for e = 1, 6 do
    table.insert(bullet.x, ship.x - 5)
    table.insert(bullet.y, ship.y - 5)
    table.insert(bullet.x_speed, 10 * (dx/distance) + math.random(-10, 10)/5)-- + math.random(-10, 10)/5)
    table.insert(bullet.y_speed, 10 * (dy/distance) + math.random(-10, 10)/5)-- + math.random(-10, 10)/5)
    table.insert(bullet.color, {0, math.random(0, 2)/10 + 0.8, 0})
    table.insert(bullet.height, 9)
    table.insert(bullet.width, 9)
    table.insert(bullet.sprite, bullet1)
    table.insert(bullet.rotation, math.atan2(my - ship.y, mx - ship.x))
    table.insert(bullet.damage, 10)
    table.insert(bullet.ability, bullet_particle)
    table.insert(bullet.ability_timer, math.random(10, 20)/1000)
    table.insert(bullet.ability_cooldown, math.random(10, 20)/1000)
    table.insert(bullet.lifetime, 0.5)
    table.insert(bullet.impact_ability, 0)
  end
  cooldown = 0.6
  love.audio.stop(laser)
  love.audio.play(laser)
end

function weapon3()
  for e = 1, 1 do
    table.insert(bullet.x, ship.x - 5)
    table.insert(bullet.y, ship.y - 5)
    table.insert(bullet.x_speed, 10 * (dx/distance) * 0.8)-- + math.random(-10, 10)/5)
    table.insert(bullet.y_speed, 10 * (dy/distance) * 0.8)-- + math.random(-10, 10)/5)
    table.insert(bullet.color, {0, math.random(0, 2)/10 + 0.8, 0})
    table.insert(bullet.height, 9)
    table.insert(bullet.width, 9)
    table.insert(bullet.sprite, bullet1)
    table.insert(bullet.rotation, math.atan2(my - ship.y, mx - ship.x))
    table.insert(bullet.damage, 10)
    table.insert(bullet.ability, bullet_particle)
    table.insert(bullet.ability_timer, math.random(10, 20)/1000)
    table.insert(bullet.ability_cooldown, math.random(10, 20)/1000)
    table.insert(bullet.lifetime, 0.5)
    table.insert(bullet.impact_ability, function(a) return split_bullet(a) end)
  end
  cooldown = 0.3
  love.audio.stop(laser)
  love.audio.play(laser)
end

function ship_teleport()
  ship.x = mx + 0.001
  ship.y = my + 0.001
  for e = 1, 20 do
    phc = math.random()
    for c, b in ipairs(particle) do
      if particle[c].is_active == false then
        particle[c].x = ship.x
        particle[c].y = ship.y
        particle[c].color = {phc/2 + 0.25, phc/2 + 0.25, phc/2 + 0.25}
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
  ship.invincibility = 2
end

function activate_ship_teleport()
  if ship.energy >= 25 then
    ship.energy = ship.energy - 25
    local check = true
    for a, b in ipairs(current_abilities) do
      if current_abilities[a] == ship_teleport then check = false end
    end  
    if check then
      table.insert(ship.ability_charges, 1)
      table.insert(ship.ability_delay, 0)
      table.insert(ship.ability_timer, 0)
      table.insert(current_abilities, ship_teleport)
    end
  end
end

function ship_barrage()
  if #enemy > 0 then
    for g = 1, boss_count do
      local ph = math.random(#enemy)
      local pex = ship.x - 5
      local pey = ship.y - 5
      local px = enemy[ph].x - pex
      local py = enemy[ph].y - pey
      local pdistance = math.sqrt(px * px + py * py)
      for a, b in ipairs(bullet) do
        if not bullet[a].is_active then
          bullet[a].x = ship.x - 5
          bullet[a].y = ship.y - 5
          bullet[a].x_speed = 15 * (px/pdistance)
          bullet[a].y_speed = 15 * (py/pdistance)
          bullet[a].color = {1, math.random(0, 0.2) + 0.8, 0}
          bullet[a].height = 15
          bullet[a].width = 15
          bullet[a].sprite = bullet1
          bullet[a].rotation = 0
          bullet[a].damage = 10
          bullet[a].ability = bullet_particle
          bullet[a].ability_timer = math.random(10, 20)/1000
          bullet[a].ability_cooldown = math.random(10, 20)/1000
          bullet[a].lifetime = 1
          bullet[a].impact_ability = 0
          bullet[a].is_active = true
          break
        end
      end
    end
  end
  love.audio.stop(laser)
  love.audio.play(laser)
end

function activate_ship_barrage()
  if ship.energy >= 75 then
    ship.energy = ship.energy - 75
    local check = true
    for a, b in ipairs(current_abilities) do
      if current_abilities[a] == ship_barrage then check = false end
    end  
    if check then
      table.insert(ship.ability_charges, 25)
      table.insert(ship.ability_delay, 0.05)
      table.insert(ship.ability_timer, 0)
      table.insert(current_abilities, ship_barrage)
    end
  end
end

function split_bullet(a)
  table.insert(explosion.x, bullet.x[a])
  table.insert(explosion.y, bullet.y[a])
  table.insert(explosion.scale, 1)
  table.insert(explosion.limit, 30)
  table.insert(explosion.decay, 100)
  table.insert(explosion.color, {0, 0.9, 0})

  table.insert(bullet.x, bullet.x[a] - 5)
  table.insert(bullet.y, bullet.y[a] - 5)
  table.insert(bullet.x_speed, -8)-- + math.random(-10, 10)/5)
  table.insert(bullet.y_speed, 0)-- + math.random(-10, 10)/5)
  table.insert(bullet.color, {0, math.random(0, 2)/10 + 0.8, 0})
  table.insert(bullet.height, 9)
  table.insert(bullet.width, 9)
  table.insert(bullet.sprite, bullet1)
  table.insert(bullet.rotation, 0)
  table.insert(bullet.damage, 10)
  table.insert(bullet.ability, bullet_particle)
  table.insert(bullet.ability_timer, math.random(10, 20)/1000)
  table.insert(bullet.ability_cooldown, math.random(10, 20)/1000)
  table.insert(bullet.lifetime, 0.3)
  table.insert(bullet.impact_ability, 0)
  
  table.insert(bullet.x, bullet.x[a] - 5)
  table.insert(bullet.y, bullet.y[a] - 5)
  table.insert(bullet.x_speed, 8)-- + math.random(-10, 10)/5)
  table.insert(bullet.y_speed, 0)-- + math.random(-10, 10)/5)
  table.insert(bullet.color, {0, math.random(0, 2)/10 + 0.8, 0})
  table.insert(bullet.height, 9)
  table.insert(bullet.width, 9)
  table.insert(bullet.sprite, bullet1)
  table.insert(bullet.rotation, 0)
  table.insert(bullet.damage, 10)
  table.insert(bullet.ability, bullet_particle)
  table.insert(bullet.ability_timer, math.random(10, 20)/1000)
  table.insert(bullet.ability_cooldown, math.random(10, 20)/1000)
  table.insert(bullet.lifetime, 0.3)
  table.insert(bullet.impact_ability, 0)
  
  table.insert(bullet.x, bullet.x[a] - 5)
  table.insert(bullet.y, bullet.y[a] - 5)
  table.insert(bullet.x_speed, 0)-- + math.random(-10, 10)/5)
  table.insert(bullet.y_speed, -8)-- + math.random(-10, 10)/5)
  table.insert(bullet.color, {0, math.random(0, 2)/10 + 0.8, 0})
  table.insert(bullet.height, 9)
  table.insert(bullet.width, 9)
  table.insert(bullet.sprite, bullet1)
  table.insert(bullet.rotation, 0)
  table.insert(bullet.damage, 10)
  table.insert(bullet.ability, bullet_particle)
  table.insert(bullet.ability_timer, math.random(10, 20)/1000)
  table.insert(bullet.ability_cooldown, math.random(10, 20)/1000)
  table.insert(bullet.lifetime, 0.3)
  table.insert(bullet.impact_ability, 0)
  
  table.insert(bullet.x, bullet.x[a] - 5)
  table.insert(bullet.y, bullet.y[a] - 5)
  table.insert(bullet.x_speed, 0)-- + math.random(-10, 10)/5)
  table.insert(bullet.y_speed, 8)-- + math.random(-10, 10)/5)
  table.insert(bullet.color, {0, math.random(0, 2)/10 + 0.8, 0})
  table.insert(bullet.height, 9)
  table.insert(bullet.width, 9)
  table.insert(bullet.sprite, bullet1)
  table.insert(bullet.rotation, 0)
  table.insert(bullet.damage, 10)
  table.insert(bullet.ability, bullet_particle)
  table.insert(bullet.ability_timer, math.random(10, 20)/1000)
  table.insert(bullet.ability_cooldown, math.random(10, 20)/1000)
  table.insert(bullet.lifetime, 0.3)
  table.insert(bullet.impact_ability, 0)
end

