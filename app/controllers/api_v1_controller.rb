class ApiV1Controller < ApplicationController
  def get_filers
    filers = Organization.joins(:filings).distinct
    render json: filers
  end

  def get_filings
    query = Filing.all
    if params["filer_id"] != nil
      query = query.where filer_id: params["filer_id"]
    end
    if params["order"] == "return_time_asc"
      ordering = "return_time ASC"
    else
      ordering = "return_time DESC" # default
    end
    query = query.order ordering
    render json: query.all
  end

  def get_awards
    query = Award.all
    if params["filing_id"] != nil
      query = query.where filing_id: params["filing_id"]
    end
    if params["order"] == "created_at_asc"
      ordering = "created_at ASC"
    else
      ordering = "created_at DESC" # default
    end
    query = query.order ordering
    render json: query.all
  end

  def get_recipients
    query = Organization.joins(:awards).distinct
    if params["filing_id"] != nil
      query = query.where "awards.filing_id = ?", params["filing_id"]
    end
    if params["state_code"] != nil
      query = query.where "organizations.state_code = ?", params["state_code"]
    end
    if params["cash_amount"] != nil
      if params["cash_amount_operator"] == "greater"
        operator = ">"
      elsif params["cash_amount_operator"] == "less"
        operator = "<"
      else
        operator = "="
      end
      query = query.where "awards.cash_amount #{operator} ?", params["cash_amount"].to_i
    end
    if params["order"] == "created_at_asc"
      ordering = "created_at ASC"
    else
      ordering = "created_at DESC" # default
    end
    query = query.order ordering
    render json: query.all
  end
end
