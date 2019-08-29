def base_url
  ENV.fetch('BASE_URL', 'https://qa-services.dev/')
end

def driver_type
  ENV.fetch('DRIVER', 'local').upcase
end