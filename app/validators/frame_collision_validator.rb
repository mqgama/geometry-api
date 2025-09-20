class FrameCollisionValidator < ActiveModel::Validator
  def validate(record)
    Frame.where.not(id: record.id).find_each do |other_frame|
      if collides_or_touches?(record, other_frame)
        record.errors.add(:base, "Frame não pode colidir ou encostar em outro frame (ID: #{other_frame.id})")
      end
    end
  end

  private

  def collides_or_touches?(frame1, frame2)
    !(frame1.right < frame2.left ||
      frame1.left > frame2.right ||
      frame1.top < frame2.bottom ||
      frame1.bottom > frame2.top)
  end
end
