-- ///////////////////////////////////////////////////////////////
--// VARS
--///////////////////////////////////////////////////////////////

-- BEHAVIOR

-- index of emenies - control each moving turn
local enemy_ref

-- change behavior 
local trocar_comp = 0  -- odds of change bahavior
local local_var = "on"  -- ativa e desativa variaveis locais -- executado 1 vez por inimigo

-- factory funtion
local function tab_add()
  return {x = 0, y = 0}
end

-- ///////////////////////////////////////////////////////////////
--// RESET BEHAVAIOR
--///////////////////////////////////////////////////////////////

local function comp_reset() 
  for i,v in ipairs(enen_list) do
    if enen_list[i].comp ~= "dead" then
      enen_list[i].comp = state.enemy.comp_random[love.math.random(1, 2)]
      enen_list[i].change_comp = "off" -- stop behavior change
    end
  end
  player.comp_alert = 1
end

-- ///////////////////////////////////////////////////////////////
--// CHECK IF INDEX_COMP EXCEED LIMIT
--///////////////////////////////////////////////////////////////

-- reset enemy counter
local function enen_cont_reset() for i,v in ipairs(state.enemy.counter) do state.enemy.counter[i].anim_numb = 1 end end

local function index_comp_reset()

  if state.enemy.index_comp > #enen_list then
    state.turn = "off"
    state.enemy.index_comp = 1
    enen_cont_reset() -- limpa contador

    -- contador de quanto tempo fica alerta
    if state.enemy.alert_p == "on" then state.enemy.alert_p_time = state.enemy.alert_p_time + 1 end
  
    -- contador de quanto tempo fica denconfiado
    if state.enemy.alert_d == "on" then state.enemy.alert_d_time = state.enemy.alert_d_time + 1 end
    
    -- end alert player
    if state.enemy.alert_p_time > 4 then
      comp_reset()
      state.enemy.alert_p_time = 0
      state.enemy.alert_p = "off"
      state.enemy.alert_p_first = "on"
    end
    -- end desconf player
    if state.enemy.alert_d_time > 1 then
      comp_reset()
      state.enemy.alert_d_time = 0
      state.enemy.alert_d = "off"
      state.enemy.alert_d_first = "on"
    end
    
  end

end

-- ///////////////////////////////////////////////////////////////
--// ENEMY MOVE
--///////////////////////////////////////////////////////////////

-- // change direction ////////////////////////////
-- /////////////////////////////////////////////////////////

local function muda_dire(random)

  if random == true then
    local rand_stop = love.math.random(1, 2)
    if rand_stop == 1 then enemy_ref.scaX = 1 end
    if rand_stop == 2 then enemy_ref.scaX = -1 end
  end
  if random == false then
    if player.x > enemy_ref.x then enemy_ref.scaX = 1 end
    if player.x < enemy_ref.x then enemy_ref.scaX = -1 end
  end

end

-- // movement ////////////////////////////
-- /////////////////////////////////////////////////////////

function move_max_zero() enemy_ref.m_max = 0 end -- used also on: move

  local function enem_move()

    -- if close to hero stop
    if ma_he(player,enemy_ref) == 45 and enemy_ref.comp == "alert_player" then 
      move_max_zero()
      -- attack function
      state.combat.enemy_active = "on"
      combate_update()
    end

    -- if close do body stop
    if ma_he(e_v_dead,enemy_ref) == 45 and enemy_ref.comp ~= "alert_desconf" and enemy_ref.comp ~= "alert_player" then 
      move_max_zero()
      -- muda direcao 
      muda_dire(true)
    end

    -- first time alert stop
    if enemy_ref.comp == "alert_player" and state.enemy.alert_p_first == "on" and state.move.ref_index == 0 then 
      move_max_zero()
      state.enemy.alert_p_first = "off"
    end 

    -- first time body alert stop
    if enemy_ref.comp == "alert_body" and state.enemy.alert_p_first == "on" and state.move.ref_index == 0 then 
      move_max_zero()
      state.enemy.alert_p_first = "off"
    end 

    -- first time item alert stop
    if enemy_ref.comp == "alert_item" and state.enemy.alert_p_first == "on" and state.move.ref_index == 0 then 
      move_max_zero()
      state.enemy.alert_p_first = "off"
    end 

  -----
  -- move
  -----
  move_main(enemy_ref)

end
------------------
-- END - enem_move()
------------------

-- ///////////////////////////////////////////////////////////////
--// DIRECAO PATHFIND
--///////////////////////////////////////////////////////////////

-- comp - normal
local function dire_diago_path()
  
  local tab = {}

  range_path_main(enemy_ref)

  for i,v in ipairs(state.range.open) do -- START
  
    if state.range.open[i].check == "close" then
    
      local function insert()
        table.insert(tab, tab_add())
        tab[#tab].x = state.range.open[i].x
        tab[#tab].y = state.range.open[i].y
      end
  
      if state.move.rand_path_diago == 1 then -- topo esquerda
        if state.range.open[i].x < enemy_ref.x and state.range.open[i].y < enemy_ref.y then
          insert()
        end
      end
      if state.move.rand_path_diago == 2 then -- topo direita
        if state.range.open[i].x > enemy_ref.x and state.range.open[i].y < enemy_ref.y then
          insert()
        end
      end
      if state.move.rand_path_diago == 3 then -- baixo esquerda
        if state.range.open[i].x < enemy_ref.x and state.range.open[i].y > enemy_ref.y then
          insert()
        end
      end
      if state.move.rand_path_diago == 4 then -- baixo direita
        if state.range.open[i].x > enemy_ref.x and state.range.open[i].y > enemy_ref.y then
          insert()
        end
      end

    end
  end -- END FOR

  -- se nao encontrar nada -- encerrar tudo
  if #tab == 0 then
    state.move.rand_path_diago = false
  -- GLOBAL - alimentando posicao escolhida
    state.range.fim.x = enemy_ref.x
    state.range.fim.y = enemy_ref.y

  -- GLOBAL - acabado o for desativa toda essa area
    state.range.path_end = "off"
      
    return
  end

  -- escolhendo aleatoriamente a posicao
  if state.move.rand_path_diago ~= false and #tab > 0 then
      
    local random_pos = love.math.random(1, #tab)

  -- GLOBAL - alimentando posicao escolhida
    state.range.fim.x = tab[random_pos].x
    state.range.fim.y = tab[random_pos].y

  -- GLOBAL - acabado o for desativa toda essa area
    state.range.path_end = "off"
    tab = nil
  end

end
-----

-- comp - alert_player
local function alert_path(ttype)
  
  range_path_main(enemy_ref)

  state.range.fim.x = ttype.x  ; state.range.fim.y = ttype.y
  
-- turn off
  state.range.path_end = "off"
  
end
-----

-- 0.1 // setup ////////////////////////////
-- /////////////////////////////////////////////////////////

local function setup_inicial()

    enemy_ref.m_max = 10
    local_var = "off" -- turn off setup

end

-- 0.2 // setup final ////////////////////////////
-- /////////////////////////////////////////////////////////

local function setup_final()
  
  if state.combat.enemy_active == "off" then
    -- desativa o path
    state.range.path_end = "stop" -- GLOBAL
    state.move.ref_index = 0 
    state.move.active = "off"
    
    -- change enemy
    state.enemy.index_comp = state.enemy.index_comp + 1
    
    index_comp_reset()

    local_var = "on" -- ativa novamente as variaveis locais
    
    particles_reset() -- particles
  end

end

-- 1 // comp - stop ////////////////////////////
-- /////////////////////////////////////////////////////////

local function comp_stop()
  
-- muda direcao 
  muda_dire(true)

-- chances de trocar de comportamento
  trocar_comp = love.math.random(1, 2)

-- interrompendo mudança de comportamento
  if trocar_comp == 1 then enemy_ref.change_comp = "on" end

end

-- 2 // comp - path_diago ////////////////////////////
-- /////////////////////////////////////////////////////////

local function comp_path_diago()

  -- setup inicial
  -- ativa e desativa variaveis locais -- executado 1 vez por inimigo
  if local_var == "on" then
  -- random direction
    state.move.rand_path_diago = love.math.random(1, 4)
    setup_inicial()
  end

  -- escolhendo a direcao
  if state.range.path_end == "stop" and enemy_ref.m_max > 0 then -- GLOBAL
    dire_diago_path() 
  end

  -- ativa path find
  if state.range.path_end == "off" then -- GLOBAL
    range_path_final(enemy_ref)
  end

  -- so ativa somente quando o path find acabar suas opearacoes
  if state.range.path_end == "on" then -- GLOBAL
    enem_move() -- movimento
  end 

  -- finalizacao do movimento
  if enemy_ref.m_max == 0 then

    -- chances de trocar de comportamento
    trocar_comp = love.math.random(1, 2) -- 1 chance em 2
    if trocar_comp == 1 then enemy_ref.change_comp = "on" end
    setup_final()

  end

end 

-- 3 // comp - sleep ////////////////////////////
-- /////////////////////////////////////////////////////////

local function comp_sleep()

-- chances de trocar de comportamento
  trocar_comp = love.math.random(1, 3) -- 1 chance em 2

-- interrompendo mudança de comportamento
  if trocar_comp == 1 then enemy_ref.change_comp = "on" end

end

-- 4 // comp - dead ////////////////////////////
-- /////////////////////////////////////////////////////////

local function comp_dead()

    setup_final()
-- chances de trocar de comportamento
    trocar_comp = 0

end

-- ///////////////////////////////////////////////////////////////
--// ALERTA
--///////////////////////////////////////////////////////////////

-- 1 // alert - descon ////////////////////////////
-- /////////////////////////////////////////////////////////

local function alert_descon()

-- setup inicial
-- ativa e desativa variaveis locais -- executado 1 vez por inimigo
if local_var == "on" then
    setup_inicial()
end

-- escolhendo a direcao
if state.range.path_end == "stop" then -- GLOBAL
    alert_path(player)
end

-- ativa path find
if state.range.path_end == "off" then -- GLOBAL
    range_path_final(enemy_ref)
end

-- so ativa somente quando o path find acabar suas opearacoes
if state.range.path_end == "on" then -- GLOBAL
    muda_dire(false) -- vira inimigo em direcao ao heroi
    enem_move() -- movimento
end 
  
-- finalizacao do movimento
if enemy_ref.m_max == 0 then
    setup_final()
end

end
------------------
-- END - alert_descon()
------------------

-- 2 // alert - player ////////////////////////////
-- /////////////////////////////////////////////////////////

local function alert_player()

-- setup inicial
-- ativa e desativa variaveis locais -- executado 1 vez por inimigo
if local_var == "on" then
    setup_inicial()
end

-- escolhendo a direcao
if state.range.path_end == "stop" then -- GLOBAL
    if enemy_ref.comp == "alert_body" then
        alert_path(e_v_dead)
    elseif enemy_ref.comp == "alert_item" then
        alert_path(e_v_item)
    elseif enemy_ref.comp == 'alert_player' then
        alert_path(player)
    end
end

-- ativa path find
if state.range.path_end == "off" then -- GLOBAL
    range_path_final(enemy_ref)
end

-- so ativa somente quando o path find acabar suas opearacoes
if state.range.path_end == "on" then -- GLOBAL

  if enemy_ref.comp == "alert_body" then
      -- nil
  else
      muda_dire(false) 
  end

  enem_move() -- movimento

end 
 
-- finalizacao do movimento
if enemy_ref.m_max == 0 then
  setup_final()
end
  
end
------------------
-- END - alert_player()
------------------

-- ///////////////////////////////////////////////////////////////
--// COMPORTAMENTOS
--///////////////////////////////////////////////////////////////

-- 0 // estrutura principal ////////////////////////////
-- /////////////////////////////////////////////////////////

function comp_padrao()

  enemy_ref = enen_list[state.enemy.index_comp]

  -- ativar animacao/avanco da contagem
  if enemy_ref.comp ~= "dead" then 
    state.enemy.counter[state.enemy.index_comp].anim_numb = 2 -- mudando animcao do item da contagem
  end 

  -- random behavior
  if state.enemy.index_comp <= #enen_list and enemy_ref.change_comp == "on" then
    enemy_ref.comp = state.enemy.comp_random[love.math.random(1, 3)] -- escolha de comportamento
    enemy_ref.change_comp = "off" -- interrompendo mudança de comportamento
  end

  -- lista de comportamentos
  if state.turn ~= "off" then
    
    if enemy_ref.comp == "stop" then
      enemy_ref.main_anim = 1
      comp_stop()
    end
    if enemy_ref.comp == "path_diago" then
      enemy_ref.main_anim = 3
      comp_path_diago()
    end
    if enemy_ref.comp == "sleep" then
      enemy_ref.main_anim = 4
      comp_sleep()
    end
    if enemy_ref.comp == "alert_desconf" then
      enemy_ref.main_anim = 3
      alert_descon()
    end
    if enemy_ref.comp == "alert_player" or enemy_ref.comp == "alert_body" or enemy_ref.comp == "alert_item" then
      enemy_ref.main_anim = 3
      alert_player()
      state.enemy.alert_d_time = 0 -- empty in case alert player is set
    end
    if enemy_ref.comp == "dead" then
      enemy_ref.main_anim = 4
      enemy_ref.alert_anim = 1 
      comp_dead()
    end
    if enemy_ref.comp == "confuse" then 
      comp_stop()
      enemy_ref.alert_anim = 6
    end

  end

end