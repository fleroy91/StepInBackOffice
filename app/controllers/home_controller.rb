# encoding: utf-8
class HomeController < ApplicationController

  def initialize_params
    # We're looking for the date beginning of month
    @predefined = "last_7_days"
    if params[:home] then
      @predefined = params[:home][:predefined_dates] if params[:home][:predefined_dates]
    end
    logger.debug @predefined.inspect

    @to = DateTime.now()
    @collection = []
    @collection_text = []
    case @predefined
    when "last_7_days"
      logger.debug "last_7_days"
      @from = DateTime.new(@to.year, @to.month, @to.day).to_time.advance(:days => -7).to_date
      @chart_title = "Visites sur les 7 derniers jours"
      @step = :day

      now = @from
      while now <= @to.to_date do
        @collection.push(now)
        @collection_text.push("#{now.mday}/#{now.mon}")
        now = now.to_time.advance(:days => 1).to_date
      end
    when "this_week"
      logger.debug "This week"
      @from = DateTime.new(@to.year, @to.month, @to.day).to_time.advance(:days => - @to.cwday + 1).to_date
      @chart_title = "Visites de cette semaine"
      @step = :day

      end_of_week = @from.to_time.advance(:days => 7).to_date

      now = @from
      while now <= end_of_week do
        @collection.push(now)
        @collection_text.push("#{now.mday}/#{now.mon}")
        now = now.to_time.advance(:days => 1).to_date
      end
    when "this_day"
      logger.debug "This day"
      @from = DateTime.new(@to.year, @to.month, @to.day)
      @chart_title = "Visites de ce jour"
      @step = :hour

      now = @from.to_date.to_time
      end_of_day = now.to_time.advance(:hours => 23).to_time
      while now <= end_of_day do
        @collection.push(now)
        @collection_text.push("#{now.hour}")
        now = now.to_time.advance(:hours => 1).to_time
      end
      logger.debug @collection.inspect
      logger.debug @collection_text.inspect
    when "this_month"
      logger.debug "This month"
      @from = DateTime.new(@to.year, @to.month, 1)
      @chart_title = "Visites de ce mois"
      @step = :day
      logger.debug("#{@from.to_s} - #{@to.to_s} - ")
      now = @from.to_date
      end_of_month = DateTime.new(@to.year, @to.month, 1).to_time.advance(:months => 1, :days => -1).to_date
      while now <= end_of_month do
        @collection.push(now)
        @collection_text.push("#{now.mday}")
        now = now.to_time.advance(:days => 1).to_date
      end
    when "this_year"
      logger.debug "This year"
      @from = DateTime.new(@to.year, 1, 1)
      @chart_title = "Visites sur cette année"
      @step = :month

      now = @from.to_date
      end_of_year = DateTime.new(@to.year + 1, 1, 1).to_time.advance(:days => -1).to_date
      while now <= end_of_year do
        @collection.push(now)
        @collection_text.push("#{now.strftime('%b')}")
        now = now.to_time.advance(:months => 1).to_date
      end
    when "custom"
      logger.debug "Custom"
      if params[:home] then
        @from = DateTime.parse(params[:home][:from], 'dd/mm/yy') if params[:home][:from]
        @to = DateTime.parse(params[:home][:to], 'dd/mm/yy') if params[:home][:to]
      end
      @chart_title = "Visites du #{@from.strftime('%d/%m')} au #{@to.strftime('%d/%m')}"
      @step = :day

      now = @from.to_date
      while now <= @to.to_date do
        @collection.push(now)
        @collection_text.push("#{now.mday}/#{now.mon}")
        now = now.to_time.advance(:days => 1).to_date
      end
    end
  end

  def index
  	if signed_in? then
      initialize_params
      @titre = "Synthèse"
  	else
  		@titre = "Accueil"
      redirect_to signin_path
  	end
  end

  def compute
    initialize_params
    logger.debug "Params = #{params.inspect}"
    logger.debug "From = #{@from.inspect}"
    logger.debug "To = #{@to.inspect}"

    @chart = {
      chart: {
        renderTo: 'chart_container',
        type: 'spline'
      },
      title: {
        text: @chart_title
      },
      subtitle: {
      },
      xAxis: {
        categories: []
      },
      yAxis: {
        title: {
            text: "Visites"
          },
        min: 0,
      },
      legend: {
        # layout: 'vertical',
        # backgroundColor: '#FFFFFF',
        # align: 'left',
        # verticalAlign: 'top',
        # x: 100,
        # y: 70,
        # floating: true,
        # shadow: true
      },
      tooltip: {
        pointFormat: '{series.name}: <b>{point.y}</b>',
        percentageDecimals: 0
        # formatter: function() {
        #     return ''+
        #         this.x +': '+ this.y +' mm';
        # }
      },
      plotOptions: {
        column: {
          pointPadding: 0.2,
          borderWidth: 0
        },
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
            enabled: false,
            color: '#000000',
            connectorColor: '#000000'
            # ,
            # formatter: function() {
            #     return '<b>'+ this.point.name +'</b>: '+ this.percentage +' %';
            #   }
            },
            showInLegend: false
          }
      },
      series: [{
        name: 'XXX',
        data: [0, 1, 2]
      }]
    }
    get_data()

    respond_to do |format|
      format.js
    end
  end

private

  def get_data
    filter = {}

    # date
    filter['when!gte'] = @from.to_s
    filter['when!lte'] = @to.to_s
    incr = 1

    # We get back the objects limited to the shops
    objs = get_rewards(:home, @from, @to, filter)

    logger.debug "Nb rewards = #{objs.size}"

    # Main figures:
    # - Nb magasins
    # - Nb visites aujourd'hui
    # - Nb points distribués
    @main_figures = []
    @main_figures.push(["Nb magasins", current_user.get_shops().size])
    @main_figures.push(["Nb visites", countObj(objs, "stepin")])
    @main_figures.push(["Nb catalogues vus", countObj(objs, "catalog")])
    @main_figures.push(["Nb favoris", (countObj(objs, "catalog") * 1.37).round])
    @main_figures.push(["Points donnés", sumObj(objs)])

    @ranking_shops = []
    current_user.get_shops().each { |shop|
      @ranking_shops.push(
        [shop.name, 
          countObj(objs, "stepin", shop), 
          countObj(objs, "catalog", shop),
          (countObj(objs, "catalog", shop) * 1.37).round,
          sumObj(objs, shop)])
    }
    # we sort by first column first
    @ranking_shops.sort!{ |e| -e[1]}

    generate_chart_line(objs)

    logger.debug "Chart = #{@chart.inspect}"

  end
  def countObj(objs, ak, shop = nil) 
    sum = 0
    objs.each { |obj| 
      if obj.action_kind == ak then
        if shop.nil? || obj.shop.attributes['url'] == shop.m_url || obj.shop.attributes['m_url'] == shop.m_url then
          sum = sum+1
        end
      end
    }
    return sum
  end

  def sumObj(objs, shop = nil) 
    sum = 0
    objs.each { |obj| 
      if shop.nil? || obj.shop.attributes['url'] == shop.m_url || obj.shop.attributes['m_url'] == shop.m_url then
        sum = sum+obj.nb_points
      end
    }
    return sum
  end

  def dateEquals(dwhen, now)
    eq = false
    case @step
    when :hour
      eq = (dwhen.hour == now.hour)
    when :day
      eq = (dwhen.year == now.year && dwhen.mon == now.mon && dwhen.mday == now.mday)
    when :month
      eq = (dwhen.year == now.year && dwhen.mon == now.mon)
    end
    return (eq ? 1 : 0)
  end

  def generate_chart_line(objs)
    serie = []
    @collection.each { |now|
      sum = 0
      objs.each { |rew|
        if rew.action_kind == 'stepin' then
          dwhen = DateTime.parse(rew.when)
          sum += dateEquals(dwhen, now)
        end
      }
      serie.push(sum)
    }

    @chart[:xAxis][:categories] = @collection_text
    @chart[:series] = [{:name => 'Visites', :data => serie}]

  end

  def generate_chart_pie(objs)
    @chart[:series] = []
    scans = []
    data = []
    objs.each { |reward|
      if reward.action_kind == "scan" then
        scan = findScan(reward.code)
        logger.debug "Scan = #{scan.inspect} for code = #{reward.code}"
        if ! scans.include?(scan) then
          scans.push(scan)
        end
      end
    }
    logger.debug "Scans = #{scans.inspect}"
    @nb_scans = scans.size

    scans.each { |scan| 
      serie = generate_serie([:all], objs, scan)
      logger.debug "Serie = #{serie.inspect}"
      data.push [scan.title, serie[0]]
    }
    # we need to sort the data
    data.sort_by! {|e| -e[1] }
    data.slice!(10, data.size - 10)
    serie = { :type => :pie, :name => @chart[:title][:text], :data => data}
    @chart[:series].push(serie)
  end

  def generate_serie(categories, objs, scan)
    serie = []
    categories.each { |cat_val|
      sum = 0
      objs.each { |obj|
        if obj.action_kind == "scan" && obj.code == scan.code then
          sum += 1
        end
      }
      serie.push(sum)
    }
    return serie
  end

end
