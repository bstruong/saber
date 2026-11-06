class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    @contacts = Contact.order(:name)
    @contacts = @contacts.where(source: params[:source]) if params[:source].present?
    @contacts = @contacts.where(soi_ring: params[:soi_ring]) if params[:soi_ring].present?
    @contacts = @contacts.where(follow_up_frequency: params[:follow_up_frequency]) if params[:follow_up_frequency].present?
  end

  def show
    @interaction = Interaction.new
    @interactions = @contact.interactions.order(created_at: :desc)
  end

  def new
    @contact = Contact.new(soi_ring: "strangers", source: "direct_referral")
  end

  def create
    if prospect_create?
      create_prospect
    else
      create_contact
    end
  end

  def edit
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: "Contact updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy!
    redirect_to contacts_path, notice: "Contact removed."
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def prospect_create?
    params[:prospect].present? || Contact::PROSPECT_SOURCES.include?(params.dig(:contact, :source))
  end

  def create_prospect
    contact = ProspectCapture.call(attrs: prospect_params)
    redirect_to prospecting_path, notice: "#{contact.name} added to the prospect queue."
  rescue ProspectCapture::Error, ActiveRecord::RecordInvalid => e
    redirect_to prospecting_path, alert: e.message
  end

  def create_contact
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to @contact, notice: "Contact created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def prospect_params
    params.require(:contact).permit(:name, :company, :profile_url, :email, :phone, :source, :notes, :hook)
  end

  def contact_params
    params.require(:contact).permit(
      :name, :email, :phone, :company, :profile_url, :source, :soi_ring,
      :goal_importance, :ring_level, :value_exchange, :past_interaction_freq,
      :objective_alignment, :notes
    )
  end
end
