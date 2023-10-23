class ApiV1Controller < ApplicationController
  # NOTE: None of these functions return errors in JSON format. Given more time, I'd want to devise
  # or adopt a standard system for sending results/metadata/errors.
  def get_filers
    query = Organization.joins(:filings).distinct.order("created_at DESC")
    if params["filer_id"] != nil
      query = query.where id: params["filer_id"]
    end
    render json: query.all
  end

  def get_filings
    query = Filing.all
    if params["filer_id"] != nil
      query = query.where filer_id: params["filer_id"]
    end
    # Standard ordering for most relevant to least relevant.
    query = query.order "tax_period DESC, amended DESC, return_time DESC"
    # Skipping pagination for now.
    render json: query.all
  end

  def get_awards
    query = Award.joins("LEFT JOIN organizations ON awards.recipient_id = organizations.id")
      .select "awards.id AS id, awards.cash_amount, awards.purpose, awards.filing_id, awards.recipient_id, organizations.name, organizations.address_line1, organizations.city, organizations.state_code, organizations.zip_code"
    render json: ApiV1Controller.build_awards_query(params, query, :select).all
  end

  def count_awards
    query = Award.joins("LEFT JOIN organizations ON awards.recipient_id = organizations.id")
    render json: ApiV1Controller.build_awards_query(params, query, :count).count
  end

  private
  # These are helpers for building API queries. Realistically, I'd probably split these off into
  # another module, but I'll but them here for simplicity.
  def self.build_awards_query(params, query, query_type)
    if params["filing_id"] != nil
      query = query.where filing_id: params["filing_id"]
    end
    if params["recipient_name"] != nil
      query = query.where "organizations.name LIKE ?", "%#{params["recipient_name"]}%"
    end
    if params["city"] != nil
      query = query.where "organizations.city = ?", params["city"]
    end
    if params["state_code"] != nil
      query = query.where "organizations.state_code = UPPER(?)", params["state_code"]
    end
    if params["zip_code"] != nil
      query = query.where "organizations.zip_code = ?", params["zip_code"]
    end
    if params["cash_amount"] != nil
      query = query.where "organizations.zip_code = ?", params["zip_code"]
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
    if query_type == :select
      if params["order"] == "name_desc"
        ordering = "organizations.name DESC"
      else
        ordering = "organizations.name ASC"
      end
      query = query.order ordering
      query = ApiV1Controller.paginate params, query
    end
    return query
  end

  def self.paginate(params, query)
    # We'll use offset pagination for this demo. Depending on the amount of data, this can lead to
    # poor performance because we have to read and throw out a bunch of rows.
    # In production, unless I was pretty confident that the table we're querying is going to be
    # small (i.e. less than 10k rows), I'd probably implement cursor based pagination. This is more
    # involved, and specific to each table, but yields better performance.
    page_size = params["page_size"]&.to_i || 10
    page = params["page"]&.to_i || 1 # 1 index because it reads better in the URL
    return query.offset((page - 1) * page_size).limit(page_size)
  end
end
